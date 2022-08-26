import pkg/norm/[
  model,
  pragmas
]

type
  Info* = ref object of Model
    ## Document info
    docName*: string ## The name of the document
    description*: string
    language*: string
    detailedInfo*: string
    origin*: string

proc newInfo*(
  docName: string;
  description, language: string;
  detailedInfo: string;
  origin: string
): Info =
  ## Creates new `Info`
  new result
  result.docName = docName
  result.description = description
  result.language = language
  result.detailedInfo = detailedInfo
  result.origin = origin

proc newInfo*: Info =
  ## Creates new blank `Info`
  newInfo(
    docName = "",
    description = "",
    language = "",
    detailedInfo = "",
    origin = "",
  )
