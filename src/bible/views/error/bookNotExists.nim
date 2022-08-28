from std/httpcore import Http404
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc bookNotExists*(book: string): View =
  result.code = Http404
  result.name = "Book not exists"
  result.vnode = buildHtml(tdiv):
    h1:
      text "Book not exists: "
      text book
