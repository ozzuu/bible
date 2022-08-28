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

import bible/db/models/[
  book,
  info,
  verse,
  document
]

proc addDb(db, docName, fullName: string; user = ""; pass = "") =
  ## Adds `db` to the `documents` db defined at `.env`
  echo fmt"Adding document '{db}' as '{docName}'"
  inDb:
    dbConn = sqlite.open(dbHost, dbUser, dbPass, "")
    setup dbConn

  var newDbConn = dbSqlite.open(db, user, pass, "")

  proc getInDb(columns: openArray[string]; table: string; orderBy = ""): seq[seq[string]] =
    var query = fmt"""SELECT {columns.join ", "} FROM ?"""
    if orderBy.len > 0:
      query.add fmt" ORDER BY {orderBy}"
    result = dbSqlite.getAllRows(newDbConn, sql query, table)
    if debugging:
      if result.len > 5:
        result = result[0..5]
  proc enumToSeq(e: type): seq[string] =
    for x in e:
      result.add $x

  block addDoc:
    echo "Adding document"
    var doc = newDocument(
      shortName = docName,
      name = fullName
    )
    inDb: sqlite.insert(dbConn, doc)


  block getInfo:
    echo "Adding info"
    type Book = enum
      name, value

    let infos = getInDb(enumToSeq Book, "info")

    var inf = newInfo()
    inf.docName = docName
    for info in infos:
      let val = info[ord value]
      case info[ord name]:
        of "description": inf.description = val
        of "language": inf.language = val
        of "detailed_info": inf.detailedInfo = val
        of "origin": inf.origin = val
        of "history_of_changes": inf.changelog = val
        else: discard

    inDb: sqlite.insert(dbConn, inf)

  var bookChapters: Table[int, seq[int]]

  block getVerses:
    echo "Adding verses"
    type Chapter = enum
      book_number, chapter, verse, text

    let verses = getInDb(enumToSeq Chapter, "verses")
    
    for v in verses:
      var ver = newVerse(
        docName = docName,
        bookShortName = v[ord book_number],
        chapter = parseInt v[ord chapter],
        number = parseInt v[ord verse],
        text = v[ord text]
      )
      echo ver[]
      let bookNumber = parseInt v[ord book_number]
      if bookChapters.hasKey bookNumber:
        if ver.chapter notin bookChapters[bookNumber]:
          bookChapters[bookNumber].add ver.chapter
      else:
        bookChapters[bookNumber] = @[ver.chapter]
      inDb: sqlite.insert(dbConn, ver)

  block getBooks:
    echo "Adding books"
    type Book = enum
      book_number, book_color, short_name, long_name, is_present

    let books = getInDb(enumToSeq Book, "books_all", $bookNumber)

    for b in books:
      if b[ord isPresent] == "0":
        continue
      var book = newBook(
        docName = docName,
        color = b[ord bookColor],
        shortName = b[ord shortName],
        name = b[ord longName],
        verses = 0,
        number = parseInt b[ord book_number],
      )
      echo book[]
      try:
        book.verses = bookChapters[book.number].len
        block updateBookShortNameInVerses:
          var verses = @[newVerse()]
          inDb: dbConn.select(verses, "Verse.bookShortName = ?", dbValue book.number)
          for verse in verses.mitems:
            verse.bookShortName = book.shortName
            inDb: dbConn.update verse

        inDb: sqlite.insert(dbConn, book)
      except KeyError:
        echo fmt"Skipping book '{book.name}' because it is blank"

when isMainModule:
  import pkg/cligen
  dispatchMulti([bible.serve], [
    addDb,
    short = {"docName": 'n'}
  ])
else:
  {.fatal: "This app cannot be imported.".}
