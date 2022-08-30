import pkg/norm/[
  model,
  pragmas
]

type
  Book* = ref object of Model
    ## Book in document
    docName*: string ## The name of the document
    color*: string
    shortName*: string
    name*: string
    chapters*: int
    number*: int

proc newBook*(
  docName, color, shortName, name: string;
  chapters, number: int
): Book =
  ## Creates new `Book`
  new result
  result.docName = docName
  result.color = color
  result.shortName = shortName
  result.name = name
  result.chapters = chapters
  result.number = number

proc newBook*: Book =
  ## Creates new blank `Book`
  newBook(
    docName = "",
    color = "",
    shortName = "",
    name = "",
    chapters = 0,
    number = 0
  )

import bible/db

proc getAllBooks*(doc: string): seq[Book] =
  result = @[newBook()]
  try:
    inDb: dbConn.select(result, "Book.docName = ?", dbValue doc)
  except: discard

proc getChaptersQnt*(doc, bookShortName: string): int =
  var book = newBook()
  try:
    inDb: dbConn.select(book, "Book.docName = ? and Book.shortName = ?", dbValue doc, dbValue bookShortName)
  except: discard
    
  result = book.chapters
