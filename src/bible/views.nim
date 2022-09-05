from std/strformat import fmt, `&`

import pkg/prologue except appName
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/config import withConf, appName
from bible/utils import assetUrl

type View* = tuple
  name: string
  vnode: VNode
  code: HttpCode

proc render*(ctx: Context; accesses: int; view: View) =
  ## Renders the karax element
  var vnode: VNode
  withConf:
    vnode = buildHtml(html):
      head:
        meta(charset = "UTF-8")
        meta(`http-equiv` = "X-UA-Compatible", content = "IE=edge")
        meta(name = "viewport", content = "width=device-width, initial-scale=1.0")
        title: text fmt"{view.name} - {appName}"
        link(rel = "stylesheet", href = assetUrl "style/third/mvp.min.css")
        link(rel = "stylesheet", href = assetUrl "style/third/fontawesome.min.css")
        link(rel = "stylesheet", href = assetUrl "style/bible.css")
      body:
        tdiv(class = "content"):
          view.vnode
          if accesses > 0:
            footer:
              tdiv(class = "accesses"):
                text fmt"This page was accessed {accesses} times in this month"
        footer:
          tdiv(class = "contribute"):
            text "This site is open-source! You can contribute at "
            a(href = "https://github.com/ozzuu/bible", rel = "noreferrer",
                target = "_blank"):
              text "ozzuu/bible"
          tdiv(class = "credits"):
            text "Made with ♥ by "
            a(href = "https://thisago.co", rel = "noreferrer",
                target = "_blank"):
              text "thisago"
          tdiv(class = "glory"):
            text "All glory to YAHUAH"
        script(src = assetUrl "script/incAccess.js")

  resp(&"<!DOCTYPE html>\l{vnode}", view.code)
