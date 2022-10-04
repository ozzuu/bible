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

type CompareDocVerse* = tuple
  doc, docName: string
  verse: Verse

proc compare*(
  docsVerse: openArray[CompareDocVerse];
  book: string;
  chapter, verse: int;
  versesQnt: int64
): View =
  let current = fmt"{book} {chapter}:{verse}"
  var docs: seq[string]
  for x in docsVerse:
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

      p:
        text fmt"Found {docsVerse.len} translations"

      details(class = "config"):
        summary: text "Config"
        label:
          input(`type` = "checkbox", id = "strongs")
          text "Strongs"
        label:
          input(`type` = "checkbox", id = "explanations")
          text "Explanations"

      tdiv(class = "verses"):
        for docVerse in docsVerse:
          tdiv(class = "version"):
            tdiv(class = "title"):
              a(href = fmt"/{docVerse.doc}/{docVerse.verse.bookShortName}/{chapter}#{verse}"):
                text docVerse.docName
            tdiv(class = "verse", id = docVerse.doc):
              sup: a(href = fmt"#{docVerse.doc}"): text $docVerse.verse.number
              span: verbatim docVerse.verse.text.parseVerse
      
      script(src = assetUrl "script/verse.js")
