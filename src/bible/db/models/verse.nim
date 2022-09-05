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

proc getAllChapterVerses*(doc, bookShortName: string; chapter: int): seq[Verse] =
  ## Get all the chapter verses of same book and document
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
  ## Get the verse
  result = newVerse()
  try:
    inDb: dbConn.select(
      result,
      "Verse.docName = ? and Verse.bookShortName = ? and Verse.chapter = ? and Verse.number = ?",
      dbValue doc, dbValue bookShortName, dbValue chapter, dbValue verse
    )
  except: discard

proc getVersesQnt*(doc, bookShortName: string; chapter: int): int64 =
  ## Returns the quantity of verses in a chapter
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

from std/strformat import fmt
from bible/config import itemsPerPage

proc search*(doc, query: string; page: int): tuple[results: seq[Verse]; matched: int64] =
  ## Searches all verses that have the `query` in same document
  result.results = @[newVerse()]
  result.matched = 0
  try:
    inDb:
      result.matched = dbConn.count(
        Verse,
        "number",
        dist = false,
        cond = "Verse.docName = ? and Verse.text like ?",
        dbValue doc, dbValue fmt"%{query}%"
      )
      dbConn.select(
        result.results,
        fmt"Verse.docName = ? and Verse.text like ? LIMIT {itemsPerPage} OFFSET {(page - 1) * itemsPerPage}",
        dbValue doc, dbValue fmt"%{query}%"
      )
  except: discard
