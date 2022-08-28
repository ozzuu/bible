from std/httpcore import Http404
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/views import View

proc chapterNotExists*(chapter: int): View =
  result.code = Http404
  result.name = "Chapter not exists"
  result.vnode = buildHtml(tdiv):
    h1:
      text "Chapter not exists: "
      text $chapter
