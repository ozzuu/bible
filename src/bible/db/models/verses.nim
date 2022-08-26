import pkg/norm/[
  model,
  pragmas
]

type
  Verse* = ref object of Model
    ## A verse of a book in document
    bookNumber*: int
    chapter*: int
    verse*: int
    text*: string


proc newVerse*(
  bookNumber, chapter, verse: int;
  text: string
): Verse =
  ## Creates new `Verse`
  new result
  result.bookNumber = bookNumber
  result.chapter = chapter
  result.verse = verse
  result.text = text

proc newVerse*: Verse =
  ## Creates new blank `Verse`
  newVerse(
    bookNumber = 0,
    chapter = 0,
    verse = 0,
    text = "",
  )
