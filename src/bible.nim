import std/logging

import pkg/prologue
import pkg/prologue/middlewares/[
  utils,
  signedCookieSession,
  staticfile
]

import bible/config
import bible/routes
import bible/db
import bible/db/setup


proc serve =
  inDb:
    dbConn = open(dbHost, dbUser, dbPass, "")
    setup dbConn

  proc setLoggingLevel(settings: Settings; errorLog, rollingLog: string): auto =
    result = proc =
      addHandler newFileLogger(errorLog, levelThreshold = lvlError)
      addHandler newRollingFileLogger rollingLog
      addHandler newConsoleLogger()
      if settings.debug:
        logging.setLogFilter(lvlDebug)
      else:
        logging.setLogFilter(lvlInfo)

  var app = newApp(
    settings = settings,
    startup = @[
      initEvent(settings.setLoggingLevel(errorLog, rollingLog))
    ]
  )

  proc sessionMw: HandlerAsync =
    ## This is a tricky way to prevent error showing to client if session
    ## was corrupted
    let mw = sessionMiddleware(settings)
    result = proc(ctx: Context) {.async.} =
      try:
        await mw ctx
      except:
        logging.info "Corrupted session"
      finally:
        await switch(ctx)

  app.use debugRequestMiddleware()
  app.use sessionMw()
  app.use staticFileMiddleware assetsDir

  for r in routesDefinition:
    app.addRoute(r.routes, r.path)
  for (code, cb) in defaultRoutes:
    app.registerErrorHandler(code, cb)

  app.run()


import std/db_sqlite
from std/strutils import join, parseInt
from std/strformat import fmt
from std/tables import Table, `[]`, `[]=`, hasKey
from std/json import parseJson, `$`, `%`, `%*`, pretty
from std/os import fileExists
import std/jsonutils

import bible/db/models/[
  book,
  info,
  verse,
  document
]

type
  DocStatus = object
    book: int
    chapter: int
    verse: int
    info: bool
  Status = Table[string, DocStatus]

proc addDb(db, docName, fullName, statusFile: string; user = ""; pass = "") =
  ## Adds `db` to the `documents` db defined at `.env`
  echo fmt"Adding document '{db}' as '{docName}'"
  inDb:
    dbConn = sqlite.open(dbHost, dbUser, dbPass, "")
    setup dbConn

  var newDbConn = dbSqlite.open(db, user, pass, "")

  if not fileExists statusFile:
    statusFile.writeFile($ %*Status())

  var stat: Status
  template inStatus(body: untyped): untyped =
    stat = statusFile.readFile.parseJson.to Status
    try:
      body
    finally:
      statusFile.writeFile(pretty %*stat)
    

  template getInDb(
    columns: openArray[string];
    table: string;
    where = "";
    body
  ): untyped =
    block:
      var query = "SELECT " & columns.join(", ") & " FROM ?"
      
      if where.len > 0:
        query.add " WHERE " & where
        
      var i = 0
      for r in dbSqlite.fastRows(newDbConn, sql query, table):
        let row {.inject.} = r
        if debugging and i > 5:
            break
        try:
          body
        finally:
          inc i


  proc enumToSeq(e: type): seq[string] =
    for x in e:
      result.add $x

  block addDoc:
    inStatus:
      if stat.hasKey docName: break addDoc
    echo "Adding document"
    var doc = newDocument(
      shortName = docName,
      name = fullName
    )
    inDb: sqlite.insert(dbConn, doc)
    inStatus: stat[docName] = DocStatus()

  block getInfo:
    inStatus:
      if stat[docName].info:
        echo "Skipping info"
        break getInfo
    echo "Adding info"
    type Info = enum
      name, value

    var inf = newInfo()
    inf.docName = docName
    getInDb(enumToSeq Info, "info", ""):
      let val = row[ord value]
      case row[ord name]:
        of "description": inf.description = val
        of "language": inf.language = val
        of "detailed_info": inf.detailedInfo = val
        of "origin": inf.origin = val
        of "history_of_changes": inf.changelog = val
        else: discard

    inDb: sqlite.insert(dbConn, inf)
    inStatus: stat[docName].info = true

  block getVerses:
    echo "Adding verses and books"
    type
      Verse {.pure.} = enum
        book_number, chapter, verse, text
      Book {.pure.} = enum
        book_number, book_color, short_name, long_name, is_present

    getInDb(enumToSeq Verse, "verses", ""):
        try:
          var ver = newVerse(
            docName = docName,
            bookShortName = "",
            chapter = parseInt row[ord Verse.chapter],
            number = parseInt row[ord Verse.verse],
            text = row[ord Verse.text]
          )
          let bookNumber = parseInt row[ord Verse.bookNumber]

          
          block addVerse:
            inStatus:
              if stat[docName].book > bookNumber:
                break addVerse
              elif stat[docName].book == bookNumber:
                if stat[docName].chapter > ver.chapter:
                  break addVerse
                elif stat[docName].chapter == ver.chapter:
                  if stat[docName].verse >= ver.number:
                    break addVerse

            var book: seq[string]
            getInDb(enumToSeq Book, "books_all", "book_number = '" & $bookNumber & "'"):
              if book.len == 0:
                book = row
              else:
                echo "WARNING: Duplicated book: " & $book
            ver.bookShortName = book[ord shortName]

            if bookNumber > stat[docName].book:
              var bok = newBook(
                docName = docName,
                color = book[ord Book.bookColor],
                shortName = book[ord Book.shortName],
                name = book[ord Book.longName],
                verses = 0,
                number = parseInt book[ord Book.bookNumber],
              )
              inDb: sqlite.insert(dbConn, bok)
              echo bok[]



            echo ver[]
            inDb: sqlite.insert(dbConn, ver)

            inStatus:
              stat[docName].book = bookNumber
              stat[docName].chapter = ver.chapter
              stat[docName].verse = ver.number
            continue
          echo fmt"Skipping verse: {ver.chapter}:{ver.number} of book {bookNumber}"
        except ValueError:
          discard

  # block getBooks:


  #   getInDb(enumToSeq Book, "books_all", $bookNumber):
  #     if row[ord isPresent] == "0":
  #       continue
  #     block addBook:
  #       try:
  #         var book = newBook(
  #           docName = docName,
  #           color = row[ord bookColor],
  #           shortName = row[ord shortName],
  #           name = row[ord longName],
  #           verses = 0,
  #           number = parseInt row[ord book_number],
  #         )
  #         inStatus:
  #           if stat[docName].book.number >= book.number:
  #             break addBook

  #         try:
  #           book.verses = bookChapters[book.number].len
  #           block updateBookShortNameInVerses:
  #             var verses = @[newVerse()]
  #             inDb: dbConn.select(verses, "Verse.bookShortName = ?", dbValue book.number)
  #             for verse in verses.mitems:
  #               verse.bookShortName = book.shortName
  #               inDb: dbConn.update verse

  #           inDb: sqlite.insert(dbConn, book)
  #           inStatus: stat[docName].book.number = book.number
  #           echo book[]
  #         except KeyError:
  #           echo fmt"Skipping book '{book.name}' because it is blank"
  #       except ValueError:
  #         discard
  #       continue
  #     echo "Skipping book"

when isMainModule:
  import pkg/cligen
  dispatchMulti([bible.serve], [
    addDb,
    short = {"docName": 'n'}
  ])
else:
  {.fatal: "This app cannot be imported.".}
