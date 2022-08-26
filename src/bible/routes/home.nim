import pkg/prologue

import bible/routeUtils

proc r_home*(ctx: Context) {.async.} =
  ## Homepage
  ctx.forceHttpMethod HttpGet
  let
    doc = ctx.getPathParams("doc")
    book = ctx.getPathParams("book")
    verse = ctx.getPathParams("verse")

  let books = getAllDocs()
  resp "Reading " & doc
