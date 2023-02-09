from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/[
  book,
  access
]
import bible/routeUtils

import bible/views
import bible/views/chapters

proc r_chapters*(ctx: Context) {.async.} =
  ## Chapters
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr

      ctx.withDoc doc:
        let chapters = doc.getChaptersQnt(book)
        ctx.withBook(book, chapters):
          echo book
          ctx.render(
            getAccess(doc, book, 0),
            chapters(doc, book, chapters)
          )
