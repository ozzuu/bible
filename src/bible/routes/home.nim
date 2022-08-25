import pkg/prologue

import bible/routeUtils

proc r_home*(ctx: Context) {.async.} =
  ## Homepage
  ctx.forceHttpMethod HttpGet
  resp "Hello World!"
