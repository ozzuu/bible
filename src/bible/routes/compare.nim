from std/strutils import contains

import pkg/prologue

from pkg/util/forStr import tryParseInt

import bible/db/models/[
  verse,
  book,
  access
]
from bible/db/models/document import getAllDocs
import bible/routeUtils

import bible/views
import bible/views/compare

proc `$`(a: Verse): string =
  $a[]

proc r_compare*(ctx: Context) {.async.} =
  ## Compare
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["book", "chapter", "verse"]):
      let
        book = node{"book"}.getStr
        chapter = node{"chapter"}.getStr.tryParseInt 0
        verse = node{"verse"}.getStr.tryParseInt 0
      var
        docsVerses: seq[CompareDocVerses]
        versesQnt = 0'i64
      for doc in getAllDocs():
        var docVerse: CompareDocVerses
        docVerse.doc = doc.shortName
        docVerse.docName = doc.name

        let chapters = doc.shortName.getChaptersQnt book
        if chapters > 0:
          let bookVerse = doc.shortName.getBookVerse(book, chapter, verse)
          if bookVerse.text.len > 0:
            docVerse.verses.add bookVerse
            docsVerses.add docVerse
        if versesQnt == 0:
          versesQnt = doc.shortName.getVersesQnt(book, chapter)
        ctx.render(
          getAccess("compare", book, chapter, verse).accesses,
          compare(docsVerses, book, chapter, verse, versesQnt)
        )
