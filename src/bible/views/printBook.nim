from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

import bible/db/models/[
  verse,
  book
]
from bible/views import View
from bible/utils import url, assetUrl
import bible/viewUtils
import bible/config

type
  ChaptersForBook* = tuple[book: string; chapters: int]

proc printBook*(
  doc: string;
  book: Book;
  chapters: int;
  verses: seq[Verse]
): View =
  result.code = Http200
  result.name = fmt"Print {doc}"
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "top"):
        tdiv: text appName
        text result.name
        span(class = "current-verse")

      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        text " - "
        a(class = "document", href = url fmt"/{doc}"): text doc
        tdiv(class = "reading"):
          a(class = "book", href = url fmt"/{doc}/{book.shortName}"): text book.name
      details(class = "config"):
        summary: text "Config"
        label:
          input(`type` = "checkbox", id = "strongs")
          text "Strongs"
        label:
          input(`type` = "checkbox", id = "explanations")
          text "Explanations"

      var verses = verses
      tdiv(class = "books"):
        tdiv(class = "chapters"):
          for chapter in 1..chapters:
            tdiv(class = "chapter"):
              text $chapter
              tdiv(class = "verses"):
                var i = 0
                for verse in verses:
                  if verse.chapter != chapter:
                    break
                  tdiv(class = "verse", id = fmt"{chapter}:{verse.number}"):
                    sup: a(href = fmt"#{chapter}:{verse.number}"): text $verse.number
                    span: verbatim verse.text.parseVerse
                  inc i
                verses = if verses.len >= i: verses[i..^1] else: @[]
          
      script(src = assetUrl "script/verse.js")
