from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

import bible/db/models/verse
from bible/views import View
from bible/utils import url, assetUrl
import bible/viewUtils
import bible/config

type SearchResult = tuple
  bookName: string
  verse: Verse

proc search*(
  doc, query: string;
  page: int;
  matched: int64;
  results: openArray[Verse];
  book = ""
): View =
  result.code = Http200
  result.name = fmt"{query} at {doc}"
  let linkAddBook = if book.len > 0: fmt"/{book}" else: ""
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "top"):
        tdiv: text appName
        text fmt"Search {result.name}"

      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        text " - "
        a(class = "document", href = url fmt"/{doc}"): text doc
        if book.len > 0:
          text " - "
          a(class = "book", href = url fmt"/{doc}/{book}"): text book
        tdiv(class = "reading"):
          span(class = "current"):
            text fmt"Search ""{query}"""
      if results.len > 0:
        details(class = "config"):
          summary: text "Config"
          label:
            input(`type` = "checkbox", id = "strongs")
            text "Strongs"
          label:
            input(`type` = "checkbox", id = "explanations")
            text "Explanations"
      p:
        text fmt"Found {matched} results, showing page {page}"
      tdiv(class = "verses"):
        for verse in results:
          tdiv(class = "result"):
            tdiv(class = "title"):
              a(href = fmt"/{doc}/{verse.bookShortName}/{verse.chapter}#{verse.number}"):
                text fmt"{verse.bookShortName} {verse.chapter}:{verse.number}"
            tdiv(class = "verse", id = $verse.number):
              sup: a(href = fmt"#{verse.number}"): text $verse.number
              span: verbatim verse.text.parseVerse.highlight query
              tdiv(class = "tools"):
                a(
                  href = fmt"/compare/{verse.bookShortName}/{verse.chapter}/{verse.number}#{doc}",
                  class = "compare",
                  title = "Compare"
                )
        if results.len == 0:
          h1: text "No results"
      tdiv(class = "pages_container"):
        # h2: text "Pages"
        tdiv(class = "pages"):
          let
            pageUrl = fmt"/{doc}{linkAddBook}/search/{query}/"
            firstPage = 1
            lastPage = if matched mod itemsPerPage == 0: matched div itemsPerPage else: (matched div itemsPerPage) + 1
          var newPage = page
          if page > lastPage:
            newPage = int lastPage

          if newPage > firstPage:
            a(class = "page first", href = pageUrl & $firstPage)
          for i in countdown(2, 1):
            if newPage - i > 0:
              a(class = "page", href = pageUrl & $(newPage - i)): text $(newPage - i)
          tdiv(class = "page current"): text $page
          for i in 1..2:
            if newPage + i <= lastPage:
              a(class = "page", href = pageUrl & $(newPage + i)): text $(newPage + i)
          if newPage < lastPage:
            a(class = "page last", href = pageUrl & $lastPage)


      
      script(src = assetUrl "script/verse.js")
