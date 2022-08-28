from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url

proc verses*(doc, book: string; verses: openArray[int]): View =
  result.code = Http200
  result.name = fmt"{doc} - {book} Verses"
  result.vnode = buildHtml(tdiv):
    h1:
      text result.name
    tdiv(class = "verses"):
      for verse in verses:
        tdiv(class = "verse"):
          a(href = url fmt"/{doc}/{book}/{verse}"): text $verse

    
    # script(src = "script/home.js") # getJs "home"
