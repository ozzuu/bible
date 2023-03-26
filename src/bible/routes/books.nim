from std/strformat import fmt

import pkg/prologue

import bible/db/models/[
  book,
  document,
  access
]
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
        let document = doc.getDoc
        ctx.render(
          getAccess(doc, "", 0),
          books(document, doc.getAllBooks)
        )
