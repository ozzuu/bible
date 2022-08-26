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

proc newBook*(
  docName, color, shortName, name: string;
): Book =
  ## Creates new `Book`
  new result
  result.docName = docName
  result.color = color
  result.shortName = shortName
  result.name = name

proc newBook*: Book =
  ## Creates new blank `Book`
  newBook(
    docName = "",
    color = "",
    shortName = "",
    name = ""
  )
