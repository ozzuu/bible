import pkg/norm/[
  model,
  pragmas
]

type
  Verse* = ref object of Model
    ## A verse of a book in document
    docName*: string ## The name of the document
    bookNumber*: int
    chapter*: int
    verse*: int
    text*: string


proc newVerse*(
  docName: string;
  bookNumber, chapter, verse: int;
  text: string
): Verse =
  ## Creates new `Verse`
  new result
  result.docName = docName
  result.bookNumber = bookNumber
  result.chapter = chapter
  result.verse = verse
  result.text = text

proc newVerse*: Verse =
  ## Creates new blank `Verse`
  newVerse(
    docName = "",
    bookNumber = 0,
    chapter = 0,
    verse = 0,
    text = "",
  )
