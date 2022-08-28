from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url

proc documents*(documents: openArray[string]): View =
  result.code = Http200
  result.name = fmt"Documents"
  result.vnode = buildHtml(tdiv):
    h1:
      text result.name
    tdiv(class = "documents"):
      for document in documents:
        tdiv(class = "document"):
          a(href = url fmt"/{document}"): text document
    
    # script(src = "script/home.js") # getJs "home"
