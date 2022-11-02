from std/strformat import fmt
from std/strutils import contains

import pkg/prologue

import bible/db/models/[
  book,
  verse,
  access
]
import bible/routeUtils

import bible/views
import bible/views/printBook

proc r_printBook*(ctx: Context) {.async.} =
  ## print book
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr

      ctx.withDoc doc:
        var verses: seq[Verse]
        let chapters = doc.getChaptersQnt book
        ctx.withBook(book, chapters):
          for verse in doc.getAllBookVerses book:
            verses.add verse
        ctx.render(
          getAccess("print_" & doc, "", 0).accesses,
          printBook(doc, doc.getBook book, chapters, verses)
        )
