import pkg/norm/[
  model,
  pragmas
]

type
  BookName* = ref object of Model
    ## Book name of document
    number*, sortingOrder*: int
    color*, shortName*, name*: string
    isPresent*: bool

proc newBookName*(
  number, sortingOrder: int;
  color, shortName, name: string;
  isPresent = true
): BookName =
  ## Creates new `BookName`
  new result
  result.number = number
  result.sortingOrder = sortingOrder
  result.color = color
  result.shortName = shortName
  result.name = name
  result.isPresent = isPresent

proc newBookName*: BookName =
  ## Creates new blank `BookName`
  newBookName(
    number = 0,
    sortingOrder = 1,
    color = "",
    shortName = "",
    name = ""
  )
