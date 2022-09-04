from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url
import bible/config

proc chapters*(doc, book: string; chapters: int): View =
  result.code = Http200
  result.name = fmt"{doc} - {book} Chapters"
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "top"):
        tdiv: text appName
        text fmt"{doc} - {book}"
      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        text " - "
        a(class = "document", href = url fmt"/{doc}"): text doc
        tdiv(class = "reading"):
          span(class = "current"): text book
      tdiv(class = "chapters"):
        for chapter in 1..chapters:
          tdiv(class = "chapter"):
            a(href = url fmt"/{doc}/{book}/{chapter}"): text $chapter
