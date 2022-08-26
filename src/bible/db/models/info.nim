import pkg/norm/[
  model,
  pragmas
]

type
  Info* = ref object of Model
    ## Document info
    description*: string
    language*: string
    chapterStr*: string
    chapterStrPs*: string # del
    introStr*: string
    russianNum*: bool
    containAccents*: bool
    detailedInfo*: string
    addSpaceBeforeFootnoteMarker*: bool # del
    strongNumbers*: bool # del
    origin*: string

proc newInfo*(
  description, language: string;
  chapterStr = "Chapter";
  chapterStrPs, introStr: string;
  russianNum = false;
  containAccents = false;
  detailedInfo: string;
  addSpaceBeforeFootnoteMarker, strongNumbers: bool;
  origin: string
): Info =
  ## Creates new `Info`
  new result
  result.description = description
  result.language = language
  result.chapterStr = chapterStr
  result.chapterStrPs = chapterStrPs
  result.introStr = introStr
  result.russianNum = russianNum
  result.containAccents = containAccents
  result.detailedInfo = detailedInfo
  result.addSpaceBeforeFootnoteMarker = addSpaceBeforeFootnoteMarker
  result.strongNumbers = strongNumbers
  result.origin = origin

proc newInfo*: Info =
  ## Creates new blank `Info`
  newInfo(
    description = "",
    language = "",
    chapterStr = "",
    chapterStrPs = "",
    introStr = "",
    containAccents = false,
    detailedInfo = "",
    addSpaceBeforeFootnoteMarker = false,
    strongNumbers = false,
    origin = "",
  )
