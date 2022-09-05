from std/httpcore import Http404
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc queryTooSmall*(query: string): View =
  result.code = Http404
  result.name = "Search query too small"
  result.vnode = buildHtml(tdiv):
    h1:
      text fmt"The search query is too small: ""{query}"""
