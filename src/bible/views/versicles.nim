from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc versicles*(doc, book: string; verse: int; versicles: openArray[string]): View =
  result.code = Http200
  result.name = fmt"{doc} - {book} {verse}"
  result.vnode = buildHtml(tdiv):
    h1:
      text result.name
      span(class = "versicle")
    tdiv(class = "versicles"):
      for i, versicle in versicles:
        tdiv(class = "versicle"):
          sup: text $i
          span: text versicle
    
    # script(src = "script/home.js") # getJs "home"
