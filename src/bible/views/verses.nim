from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from pkg/bibleTools import identifyBibleBook, en

import bible/db/models/verse
from bible/views import View
from bible/utils import url, assetUrl
import bible/viewUtils
import bible/config

proc verses*(
  doc, book: string;
  chaptersQnt, chapter: int;
  verses: openArray[Verse];
): View =
  result.code = Http200
  result.name = fmt"{doc} - {book} {chapter}"
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "controls"):
        if chapter > 1:
          a(href = url fmt"/{doc}/{book}/{chapter - 1}", class = "previous")
        if chapter < chaptersQnt:
          a(href = url fmt"/{doc}/{book}/{chapter + 1}", class = "next")
      tdiv(class = "top"):
        tdiv: text appName
        text fmt"{doc} - {book} {chapter}"
        span(class = "current-verse")

      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        text " - "
        a(class = "document", href = url fmt"/{doc}"): text doc
        tdiv(class = "reading"):
          a(class = "book", href = url fmt"/{doc}/{book}"): text book.identifyBibleBook.book.en
          span(class = "current"):
            text $chapter
            span(class = "current-verse")
      details(class = "config"):
        summary: text "Config"
        label:
          input(`type` = "checkbox", id = "strongs")
          text "Strongs"
        label:
          input(`type` = "checkbox", id = "explanations")
          text "Explanations"

      tdiv(class = "verses"):
        for i, verse in verses:
          tdiv(class = "verse", id = $verse.number):
            sup: a(href = fmt"#{verse.number}"): text $verse.number
            span: verbatim verse.text.parseVerse
            tdiv(class = "tools"):
              a(
                href = fmt"/compare/{book}/{chapter}/{verse.number}#{doc}",
                class = "compare",
                title = "Compare"
              )
      
      script(src = assetUrl "script/verse.js")
