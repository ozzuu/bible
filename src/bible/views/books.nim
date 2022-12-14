from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url, assetUrl
from bible/db/models/book import Book
import bible/config

proc books*(doc: string; books: openArray[Book]): View =
  result.code = Http200
  result.name = fmt"{doc} books"
  withConf:
    result.vnode = buildHtml(tdiv):
      tdiv(class = "top"):
        tdiv: text appName
        text fmt"{doc}"
      tdiv(class = "title"):
        a(class = "home", href = url fmt"/"): text appName
        tdiv(class = "reading"):
          span(class = "current"): text doc
      tdiv(class = "search"):
        input(`type` = "text", id = "search", placeholder = "Search")
        button(id = "submit_search")
      tdiv(class = "books"):
        for book in books:
          tdiv(class = "book"):
            a(href = url fmt"/{doc}/{book.shortName}"):
              text book.name
      script(src = assetUrl "script/books.js")
