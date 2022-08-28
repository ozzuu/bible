from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url

proc books*(doc: string; books: openArray[string]): View =
  result.code = Http200
  result.name = fmt"{doc} books"
  result.vnode = buildHtml(tdiv):
    h1:
      text result.name
    tdiv(class = "books"):
      for book in books:
        tdiv(class = "book"):
          a(href = url fmt"/{doc}/{book}"): text book

    
    # script(src = "script/home.js") # getJs "home"
