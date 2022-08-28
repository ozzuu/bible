from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/verses

proc r_verses*(ctx: Context) {.async.} =
  ## Verses
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        verse = node{"verse"}.getInt

      ctx.withDoc doc:
        ctx.render verses(doc, book, @[1, 2, 3])
