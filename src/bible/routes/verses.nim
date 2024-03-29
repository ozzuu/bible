from std/strutils import contains

import pkg/prologue

from pkg/util/forStr import tryParseInt
from pkg/bibleTools import identifyBibleBook, enAbbr

import bible/db/models/[
  verse,
  book,
  access
]
import bible/routeUtils

import bible/views
import bible/views/verses

proc r_verses*(ctx: Context) {.async.} =
  ## Verses
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book", "chapter"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr.identifyBibleBook.book.enAbbr
        chapter = node{"chapter"}.getStr.tryParseInt 0

      ctx.withDoc doc:
        let chapters = doc.getChaptersQnt(book)
        ctx.withBook(book, chapters):
          let bookVerses = doc.getAllChapterVerses(book, chapter)
          echo bookVerses.len
          ctx.withChapter(chapter, bookVerses.len):
            ctx.render(
              getAccess(doc, book, chapter),
              verses(doc, book, chapters, chapter, bookVerses)
            )
