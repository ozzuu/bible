from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/[
  document,
  access
]
import bible/routeUtils

import bible/views
import bible/views/documents

proc r_documents*(ctx: Context) {.async.} =
  ## All documents
  ctx.forceHttpMethod HttpGet
  ctx.render(
    getAccess("", "", 0),
    documents(getAllDocs())
  )
