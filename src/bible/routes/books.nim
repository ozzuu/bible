from std/strformat import fmt

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/[
  docNotExists,
  home
]

proc r_books*(ctx: Context) {.async.} =
  ## Homepage
  ctx.forceHttpMethod HttpGet
  let
    doc = ctx.getPathParams("doc")

  let docs = getAllDocsName()
  if doc in docs:
    ctx.render home(doc, book, verse, @["verse1", "verse2", "verse3"])
  else:
    ctx.render docNotExists doc
