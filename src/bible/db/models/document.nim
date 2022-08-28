import pkg/norm/[
  model,
  pragmas
]

from bible/utils import nowUnix

type
  Document* = ref object of Model
    ## Available documents
    name*: string ## The name of the document
    createdAt*: int64

proc newDocument*(
  name: string;
): Document =
  ## Creates new `Document`
  new result
  result.name = name
  result.createdAt = nowUnix()

proc newDocument*: Document =
  ## Creates new blank `Document`
  newDocument(
    name = "",
  )

import bible/db

proc getAllDocsName*: seq[string] =
  var docs = @[newDocument()]
  inDb: dbConn.selectAll docs

  for doc in docs:
    result.add doc.name
