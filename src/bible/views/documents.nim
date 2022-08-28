from std/httpcore import Http200
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View
from bible/utils import url
import bible/config
import bible/db/models/document

proc documents*(documents: openArray[Document]): View =
  result.code = Http200
  result.name = fmt"Documents"
  withConf:
    result.vnode = buildHtml(tdiv):
      h1:
        text appName
      p: text "Documents"
      tdiv(class = "documents"):
        for document in documents:
          tdiv(class = "document"):
            a(href = url fmt"/{document.shortName}"): text document.name
      