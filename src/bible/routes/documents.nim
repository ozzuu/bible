from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/documents

proc r_documents*(ctx: Context) {.async.} =
  ## Versicles
  ctx.forceHttpMethod HttpGet
  ctx.render documents(getAllDocsName())
