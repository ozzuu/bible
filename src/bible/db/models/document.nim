import pkg/norm/[
  model,
  pragmas
]

from bible/utils import nowUnix

type
  Document* = ref object of Model
    ## Available documents
    shortName* {.unique.}: string ## The name of the document
    name*: string
    createdAt*: int64

proc newDocument*(
  shortName, name: string;
): Document =
  ## Creates new `Document`
  new result
  result.shortName = shortName
  result.name = name
  result.createdAt = nowUnix()

proc newDocument*: Document =
  ## Creates new blank `Document`
  newDocument(
    shortName = "",
    name = "",
  )

import bible/db

proc getAllDocs*: seq[Document] =
  result = @[newDocument()]
  inDb: dbConn.selectAll result

proc getAllDocsShortNames*: seq[string] =
  for doc in getAllDocs():
    result.add doc.shortName
