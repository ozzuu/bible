from std/httpcore import Http404
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc verses*(doc, book: string; verses: openArray[int]): View =
  result.code = Http404
  result.name = fmt"{doc} - {book}"
  result.vnode = buildHtml(tdiv):
    h1:
      text result.name
    tdiv(class = "verses"):
      for verse in verses:
        tdiv(class = "verse"):
          span: text $verse
    
    # script(src = "script/home.js") # getJs "home"
