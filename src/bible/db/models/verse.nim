import pkg/norm/[
  model,
  pragmas
]

type
  Verse* = ref object of Model
    ## A chapter of a book in document
    docName*: string ## The name of the document
    bookShortName*: string
    chapter*: int
    number*: int
    text*: string


proc newVerse*(
  docName, bookShortName: string;
  chapter, number: int;
  text: string
): Verse =
  ## Creates new `Verse`
  new result
  result.docName = docName
  result.bookShortName = bookShortName
  result.chapter = chapter
  result.number = number
  result.text = text

proc newVerse*: Verse =
  ## Creates new blank `Verse`
  newVerse(
    docName = "",
    bookShortName = "",
    chapter = 0,
    number = 0,
    text = "",
  )

import bible/db

proc getAllBookVerses*(doc, bookShortName: string; chapter: int): seq[Verse] =
  result = @[newVerse()]
  try:
    inDb: dbConn.select(
      result,
      "Verse.docName = ? and Verse.bookShortName = ? and Verse.chapter = ?",
      dbValue doc, dbValue bookShortName, dbValue chapter
    )
  except: discard
  if result[0].text.len == 0:
    discard pop result

proc getBookVerse*(doc, bookShortName: string; chapter, verse: int): Verse =
  result = newVerse()
  try:
    inDb: dbConn.select(
      result,
      "Verse.docName = ? and Verse.bookShortName = ? and Verse.chapter = ? and Verse.number = ?",
      dbValue doc, dbValue bookShortName, dbValue chapter, dbValue verse
    )
  except: discard

proc getVersesQnt*(doc, bookShortName: string; chapter: int): int64 =
  result = 0
  try:
    inDb:
      result = dbConn.count(
        Verse,
        "number",
        dist = true,
        cond = "Verse.docName = ? and Verse.bookShortName = ? and Verse.chapter = ?",
        dbValue doc, dbValue bookShortName, dbValue chapter
      )
  except: discard
# todo: change book id from booknum to book short name
