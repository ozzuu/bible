from std/strformat import fmt, `&`

import pkg/prologue except appName
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/config import withConf, appName
from bible/utils import assetUrl
from bible/db/models/access import Access

type View* = tuple
  name: string
  vnode: VNode
  code: HttpCode

proc render*(ctx: Context; access: Access; view: View) =
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
          if access.allAccesses > 0:
            footer:
              tdiv(class = "accesses"):
                text fmt"This page was accessed {access.monthlyAccesses} times in this month. {access.allAccesses} times in total"
        footer:
          tdiv(class = "contribute"):
            text "This site is open-source! You can contribute at "
            a(href = "https://git.ozzuu.com/ozzuu/bible", rel = "noreferrer",
                target = "_blank"):
              text "ozzuu/bible"
          tdiv(class = "credits"):
            text "Made with ♥ by "
            a(href = "https://thisago.co", rel = "noreferrer",
                target = "_blank"):
              text "thisago"
          tdiv(class = "glory"):
            text "All glory to יהוה"
        script(src = assetUrl "script/bible.js")
        script(src = assetUrl "script/incAccess.js")

  resp(&"<!DOCTYPE html>\l{vnode}", view.code)
