from std/httpcore import Http404
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc docNotExists*(doc: string): View =
  result.code = Http404
  result.name = "Document not exists"
  result.vnode = buildHtml(tdiv):
    h1:
      text "Document not exists: "
      text doc
