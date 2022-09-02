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
    statusFile.writeFile( $ %*Status())

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
    orderBy = "";
    body
  ): untyped =
    block:
      var query = "SELECT " & columns.join(", ") & " FROM ?"

      if where.len > 0:
        query.add " WHERE " & where
      if orderBy.len > 0:
        query.add " ORDER BY " & orderBy


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
    getInDb(enumToSeq Info, "info", "", ""):
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
    var booksAllTable = true
    echo "Adding verses and books"
    type
      Verse {.pure.} = enum
        book_number, chapter, verse, text
      Book {.pure.} = enum
        book_number, book_color, short_name, long_name, is_present

    getInDb(enumToSeq Verse, "verses", "", "book_number"):
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
          try:
            if not booksAllTable:
              raise newException(DbError, "")
            getInDb(enumToSeq Book, "books_all", "book_number = '" & $bookNumber & "'", ""):
              if book.len == 0:
                book = row
              else:
                echo "WARNING: Duplicated book: " & $book
          except DbError:
            if booksAllTable:
              echo "Table 'books_all' doesn't exists"
              booksAllTable = false
            var columns = enumToSeq Book
            discard pop columns
            getInDb(columns, "books", "book_number = '" & $bookNumber & "'", ""):
              if book.len == 0:
                book = row
                book.add "1"
              else:
                echo "WARNING: Duplicated book: " & $book

          ver.bookShortName = book[ord shortName]

          if bookNumber > stat[docName].book:
            var bok = newBook(
              docName = docName,
              color = book[ord Book.bookColor],
              shortName = book[ord Book.shortName],
              name = book[ord Book.longName],
              chapters = 0,
              number = parseInt book[ord Book.bookNumber],
            )
            inDb: sqlite.insert(dbConn, bok)
            echo fmt"Added book: {bok.name}"

          echo fmt"Added verse: {ver.bookShortName} {ver.chapter}:{ver.number}"
          inDb: sqlite.insert(dbConn, ver)

          inStatus:
            stat[docName].book = bookNumber
            stat[docName].chapter = ver.chapter
            stat[docName].verse = ver.number
          continue
        echo fmt"Skipping verse: {ver.chapter}:{ver.number} of book number {bookNumber}"
      except ValueError:
        discard
  echo fmt"Done, now run `bible update_chapters_quantity -d '{docName}'`"

proc updateChaptersQuantity(docName: string) =
  ## Updates the quantity of chapters of each book
  inDb:
    dbConn = sqlite.open(dbHost, dbUser, dbPass, "")

  echo fmt"Updating the quantity of chapters in '{docName}' document"

  var books = @[newBook()]
  inDb: dbConn.select(books, "Book.docName = ?", dbValue docName)

  for book in books.mitems:
    var versesQnt = 0
    inDb:
      versesQnt = int dbConn.count(Verse, "chapter", dist = true, cond = "bookShortName = ?", dbValue book.shortName)
    echo fmt"The book '{book.name}' has {versesQnt} chapters"
    book.chapters = versesQnt
    inDb: dbConn.update book

proc renameDocName(oldDocName, docName, fullDocName: string) =
  ## Updates the quantity of chapters of each book
  ## 
  ## Provide the short document name
  inDb:
    dbConn = sqlite.open(dbHost, dbUser, dbPass, "")

  echo fmt"Renaming document from '{oldDocName}' to '{fullDocName}' ({docName})"

  block renameDocument:
    try:
      var document = newDocument()
      inDb: dbConn.select(document, "Document.shortName = ?", dbValue oldDocName)
      echo fmt"Renaming document from '{document.name}' ({document.shortName}) to '{fullDocName}' ({docName})"
      document.name = fullDocName
      document.shortName = docName
      inDb: dbConn.update document
    except:
      echo fmt"Already renamed document"

  block renameBooks:
    var books = @[newBook()]
    inDb: dbConn.select(books, "Book.docName = ?", dbValue oldDocName)
    if books.len == 0:
      echo "No books to rename"
    for book in books.mitems:
      if book.docName != docName:
        echo fmt"Renaming docName of book '{book.name}' from '{book.docName}' to '{docName}'"
        book.docName = docName
        inDb: dbConn.update book
      else:
        echo fmt"The book '{book.name}' already have the '{docName}'"
      
  block renameVerses:
    var verses = @[newVerse()]
    inDb: dbConn.select(verses, "Verse.docName = ?", dbValue oldDocName)
    if verses.len == 0:
      echo "No verse to delete"
    for verse in verses.mitems:
      if verse.docName != docName:
        echo fmt"Renaming docName of verse '{verse.bookShortName} {verse.chapter}:{verse.number}' from '{verse.docName}' to '{docName}'"
        verse.docName = docName
        inDb: dbConn.update verse
      else:
        echo fmt"The verse '{verse.bookShortName} {verse.chapter}:{verse.number}' already have the '{docName}'"

proc deleteDoc(docName: string) =
  ## Deletes the document
  ## 
  ## Provide the short document name
  inDb:
    dbConn = sqlite.open(dbHost, dbUser, dbPass, "")

  echo fmt"Deleting '{docName}'"

  block renameDocument:
    try:
      var document = newDocument()
      inDb: dbConn.select(document, "Document.shortName = ?", dbValue docName)
      echo fmt"Deleting '{docName}' document"
      inDb: dbConn.delete document
    except:
      echo fmt"Already deleted document"

  block renameBooks:
    var books = @[newBook()]
    inDb: dbConn.select(books, "Book.docName = ?", dbValue docName)
    if books.len == 0:
      echo "No books to delete"
    for book in books.mitems:
      echo fmt"Deleting book '{book.name}'"
      inDb: dbConn.delete book
      
  block renameVerses:
    var verses = @[newVerse()]
    inDb: dbConn.select(verses, "Verse.docName = ?", dbValue docName)
    if verses.len == 0:
      echo "No verse to delete"
    for verse in verses.mitems:
      echo fmt"Deleting verse '{verse.bookShortName} {verse.chapter}:{verse.number}'"
      inDb: dbConn.delete verse
      

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    bible.serve
  ], [
    addDb,
    short = {"docName": 'n'}
  ],[
    updateChaptersQuantity
  ],[
    renameDocName
  ],[
    deleteDoc
  ])
else:
  {.fatal: "This app cannot be imported.".}
