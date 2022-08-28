from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/versicles

proc r_versicles*(ctx: Context) {.async.} =
  ## Versicles
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book", "verse"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        verse = node{"verse"}.getInt

      ctx.withDoc doc:
        ctx.render versicles(doc, book, verse, @["verse1", "verse2", "verse3"])
