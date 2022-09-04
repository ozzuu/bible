from std/httpcore import Http200
from std/strformat import fmt
from std/strutils import join
import pkg/karax/[
  karaxdsl,
  vdom
]

import bible/db/models/verse
from bible/views import View
from bible/utils import url, assetUrl
import bible/viewUtils
import bible/config

type CompareDocVerses* = tuple
  doc, docName: string
  verses: seq[Verse]

proc compare*(
  docVerses: openArray[CompareDocVerses];
  book: string;
  chapter, verse: int;
  versesQnt: int64
): View =
  let current = fmt"{book} {chapter}:{verse}"
  var docs: seq[string]
  for x in docVerses:
    docs.add x.doc
  result.code = Http200
  result.name = fmt"Compare {current}"
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "controls"):
        if verse > 1:
          a(href = url fmt"/compare/{book}/{chapter}/{verse - 1}", class = "previous")
        if verse < versesQnt:
          a(href = url fmt"/compare/{book}/{chapter}/{verse + 1}", class = "next")
      tdiv(class = "top"):
        tdiv: text appName
        text result.name

      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        text " - comparison"
        tdiv(class = "reading"):
          span(class = "current"):
            text current
      details(class = "config"):
        summary: text "Config"
        label:
          input(`type` = "checkbox", id = "strongs")
          text "Strongs"
        label:
          input(`type` = "checkbox", id = "explanations")
          text "Explanations"

      tdiv(class = "verses"):
        for docVerses in docVerses:
          tdiv(class = "version"):
            tdiv(class = "title"):
              a(href = fmt"/{docVerses.doc}/{book}/{chapter}#{verse}"):
                text docVerses.docName
            for verse in docVerses.verses:
              tdiv(class = "verse", id = docVerses.doc):
                sup: a(href = fmt"#{docVerses.doc}"): text $verse.number
                span: verbatim verse.text.parseVerse
      
      script(src = assetUrl "script/verse.js")
