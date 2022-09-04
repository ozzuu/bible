from std/httpcore import Http404
from std/strformat import fmt
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc verseNotExists*(doc: string; chapter, verse: int): View =
  result.code = Http404
  result.name = "Verse not exists"
  result.vnode = buildHtml(tdiv):
    h1:
      text fmt"Verse not exists: {chapter}:{verse} at {doc}"
