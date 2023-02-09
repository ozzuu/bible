from std/strformat import fmt
from std/strutils import toLowerAscii

import pkg/norm/[
  model,
  pragmas
]
from pkg/util/forStr import removeAccent

from bible/config import bookVariations

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

func getBookVariations(book: string): seq[string] =
  ## Returns all book name variations of the current book name
  let bookName = toLowerAscii removeAccent book
  for variations in bookVariations:
    for variation in variations:
      if bookName == variation.removeAccent.toLowerAscii:
        return variations

func makeBookQuery(book: string): string =
  ## Generates a query to get the book ignoring accents
  var variations = "("
  for x in getBookVariations book:
    variations.add fmt"'{toLowerAscii x}', "
  if variations.len > 1:
    variations = variations[0..^3] & ")"
  else:
    variations = fmt"('{toLowerAscii dbQuote book}')"
  result = fmt"LOWER(Verse.bookShortName) in {variations}"

proc getAllBooksVerse*(bookShortName: string; chapter, verse: int): seq[Verse] =
  ## Get same verse of all books
  result = @[newVerse()]
  let bookQuery = makeBookQuery bookShortName
  try:
    inDb: dbConn.select(
      result,
      fmt"{bookQuery} and Verse.chapter = ? and Verse.number = ?",
      dbValue chapter, dbValue verse
    )
  except:
    result = @[]
    
proc getAllBookVerses*(doc, bookShortName: string): seq[Verse] =
  ## Get same verse of all books
  result = @[newVerse()]
  try:
    inDb: dbConn.select(
      result,
      fmt"Verse.docName = ? and Verse.bookShortName = ?",
      dbValue doc, dbValue bookShortName
    )
  except:
    result = @[]

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

proc search*(doc, query: string; page: int; book = ""): tuple[results: seq[Verse]; matched: int64] =
  ## Searches all verses that have the `query` in same document
  result.results = @[newVerse()]
  result.matched = 0
  try:
    if book.len > 0:
      let cond = "Verse.docName = ? and Verse.text like ? and Verse.bookShortName = ?"
      inDb:
        result.matched = dbConn.count(
          Verse,
          "number",
          dist = false,
          cond = cond,
          dbValue doc, dbValue fmt"%{query}%", dbValue book
        )
        dbConn.select(
          result.results,
          fmt"{cond} LIMIT {itemsPerPage} OFFSET {(page - 1) * itemsPerPage}",
          dbValue doc, dbValue fmt"%{query}%", dbValue book
        )
    else:
      let cond = "Verse.docName = ? and Verse.text like ?"
      inDb:
        result.matched = dbConn.count(
          Verse,
          "number",
          dist = false,
          cond = cond,
          dbValue doc, dbValue fmt"%{query}%"
        )
        dbConn.select(
          result.results,
          fmt"{cond} LIMIT {itemsPerPage} OFFSET {(page - 1) * itemsPerPage}",
          dbValue doc, dbValue fmt"%{query}%"
        )
  except:
    discard result.results.pop
