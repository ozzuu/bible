from std/strformat import fmt

import pkg/prologue

import bible/db/models/document
import bible/routeUtils

import bible/views
import bible/views/books

proc r_books*(ctx: Context) {.async.} =
  ## List all books
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc"]):
      let doc = node{"doc"}.getStr
      ctx.withDoc doc:
        ctx.render books(doc, @["book1", "book2", "book3"])
