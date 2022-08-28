from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/[
  docNotExists,
  verses
]

proc r_verses*(ctx: Context) {.async.} =
  ## Verses
  ctx.forceHttpMethod HttpGet
  ctx.withParams(mergePath = true):
    node.ifContains(all = ["doc", "book", "verse"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        verse = node{"verse"}.getInt

      if doc in getAllDocsName():
        ctx.render verses(doc, book, @[1,2,3])
      else:
        ctx.render docNotExists doc
