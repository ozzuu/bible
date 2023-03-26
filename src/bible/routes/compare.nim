from std/strutils import contains

import pkg/prologue

from pkg/util/forStr import tryParseInt
from pkg/bibleTools import identifyBibleBook, enAbbr

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
        book = node{"book"}.getStr.identifyBibleBook.book.enAbbr
        chapter = node{"chapter"}.getStr.tryParseInt 0
        verse = node{"verse"}.getStr.tryParseInt 0
      var
        docsVerses: seq[CompareDocVerse]
        versesQnt = 0'i64
        verses = getAllBooksVerse(book, chapter, verse)
      for doc in getAllDocs():
        var docVerse: CompareDocVerse
        docVerse.doc = doc.shortName
        docVerse.docName = doc.name

        var bookVerse: Verse
        for verse in verses:
          if verse.docName == doc.shortName:
            bookVerse = verse
            break
        if not bookVerse.isNil and bookVerse.text.len > 0:
          docVerse.verse = bookVerse
          docsVerses.add docVerse
        if versesQnt == 0:
          versesQnt = doc.shortName.getVersesQnt(book, chapter)
        ctx.render(
          getAccess("compare", book, chapter, verse),
          compare(docsVerses, book, chapter, verse, versesQnt)
        )
