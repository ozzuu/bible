import pkg/prologue

from pkg/util/forStr import tryParseInt

import bible/db/models/access
import bible/routeUtils

proc r_incAccess*(ctx: Context) {.async.} =
  ## Increment access
  ctx.forceHttpMethod HttpPost
  ctx.withParams(get = false, path = false):
    node.ifContains(all = ["doc", "book", "chapter", "verse"]):
      let
        doc = node{"doc"}.getStr
        book = node{"book"}.getStr
        chapter = node{"chapter"}.getStr.tryParseInt 0
        verse = node{"verse"}.getStr.tryParseInt 0

      incAccess(doc, book, chapter, verse)

      resp "Success"
