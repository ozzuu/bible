from std/strutils import contains
from std/strformat import fmt

import pkg/prologue

from pkg/util/forStr import tryParseInt

import bible/db/models/[
  verse,
  book,
  access
]
import bible/routeUtils

import bible/views
import bible/views/search
from bible/config import itemsPerPage

proc `$`(a: Verse): string =
  $a[]

proc r_bibleSearch*(ctx: Context) {.async.} =
  ## Search
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "query", "page"]):
      let
        doc = node{"doc"}.getStr
        query = node{"query"}.getStr
        page = node{"page"}.getStr.tryParseInt 0

      ctx.withDoc doc:
        var searchResults: tuple[results: seq[Verse]; matched: int64]
        if page > 0:
          searchResults = doc.search(query, page)
        ctx.render(
          getAccess(doc, "search", 0),
          search(doc, query, page, searchResults.matched, searchResults.results)
        )

proc r_bookSearch*(ctx: Context) {.async.} =
  ## Search
  ctx.forceHttpMethod HttpGet
  ctx.withParams(get = false, path = true):
    node.ifContains(all = ["doc", "book", "query", "page"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        query = node{"query"}.getStr
        page = node{"page"}.getStr.tryParseInt 0

      ctx.withDoc doc:
        var searchResults: tuple[results: seq[Verse]; matched: int64]
        if page > 0:
          searchResults = doc.search(query, page, book)
        ctx.render(
          getAccess(doc, fmt"{book}_search", 0),
          search(doc, query, page, searchResults.matched, searchResults.results, book)
        )
