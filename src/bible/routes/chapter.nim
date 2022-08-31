from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/book
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

      echo "\l\l"
      echo book
      echo "\l\l"

      ctx.withDoc doc:
        let chapters = doc.getChaptersQnt(book)
        ctx.withBook(book, chapters):
          ctx.render chapters(doc, book, chapters)
