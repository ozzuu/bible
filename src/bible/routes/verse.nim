from std/strutils import contains

import pkg/prologue

from pkg/util/forStr import tryParseInt

import bible/db/models/[
  verse,
  book
]
import bible/routeUtils

import bible/views
import bible/views/verses

proc `$`(a: Verse): string =
  $a[]

proc r_verse*(ctx: Context) {.async.} =
  ## Verse
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book", "chapter"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        chapter = node{"chapter"}.getStr.tryParseInt 0

      ctx.withDoc doc:
        let chapters = doc.getChaptersQnt(book)
        echo chapters
        ctx.withBook(book, chapters):
          let bookVerses = doc.getAllBookVerses(book, chapter)
          ctx.withChapter(chapter, bookVerses.len):
            ctx.render verses(doc, book, chapter, bookVerses)
