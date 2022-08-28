import std/logging

import pkg/prologue
import pkg/prologue/middlewares/utils
import pkg/prologue/middlewares/signedCookieSession

import bible/config
import bible/routes
import bible/db
import bible/db/setup


proc main =
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

  app.use @[
    debugRequestMiddleware(),
    sessionMw()
  ]

  for r in routesDefinition:
    app.addRoute(r.routes, r.path)
  for (code, cb) in defaultRoutes:
    app.registerErrorHandler(code, cb)

  app.run()


import std/db_sqlite
from std/strutils import join, parseInt
from std/strformat import fmt

import bible/db/models/[
  book,
  info,
  verse
]

proc addDb(db, docName: string; user = ""; pass = "") =
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
      if result.len > 10:
        result = result[0..10]
  proc enumToSeq(e: type): seq[string] =
    for x in e:
      result.add $x


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
        name = b[ord longName]
      )
      inDb: sqlite.insert(dbConn, book)

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

  block getVerses:
    echo "Adding verses"
    type Verse = enum
      book_number, chapter, verse, text

    let verses = getInDb(enumToSeq Verse, "verses")

    for v in verses:
      var ver = newVerse(
        docName = docName,
        bookNumber = parseInt v[ord bookNumber],
        chapter = parseInt v[ord chapter],
        verse = parseInt v[ord verse],
        text = v[ord text]
      )
      inDb: sqlite.insert(dbConn, ver)

when isMainModule:
  import pkg/cligen
  dispatchMulti([main], [
    addDb,
    short = {"docName": 'n'}
  ])
else:
  {.fatal: "This app cannot be imported.".}
