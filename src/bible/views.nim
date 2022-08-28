from std/strformat import fmt, `&`

import pkg/prologue except appName
import pkg/karax/[
  karaxdsl,
  vdom
]

from bible/config import withConf, appName

type View* = tuple
  name: string
  vnode: VNode
  code: HttpCode

proc render*(ctx: Context; view: View) =
  ## Renders the karax element
  var vnode: VNode
  withConf: 
    vnode = buildHtml(html):
      head:
        title: text fmt"{view.name} - {appName}"
      body:
        view.vnode
  resp(&"<!DOCTYPE html>\l{vnode}", view.code)
