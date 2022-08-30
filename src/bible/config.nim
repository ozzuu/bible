from std/uri import Uri, parseUri
from std/strutils import parseInt

import pkg/prologue

const logicInApi* = false

const
  ifContainsAllErr* = "Please provide $1"
  ifContainsAtLeastErr* = "Please provide at least $1"
  ifContainsInvalidReq* = "Invalid request"

func parseAddress(url: Uri): tuple[hasSsl: bool] =
  ## Parses the address into `haveSsl`, `host`
  result.hasSsl = url.scheme == "https"


# import std/locks
# var confLock*: Lock
# initLock confLock

# {.push guard: confLock.} # Why push isn't working?
let
  env = loadPrologueEnv ".env"

  dbHost* = env.getOrDefault("dbHost", ":memory:")
  dbUser* = env.getOrDefault("dbUser", "")
  dbPass* = env.getOrDefault("dbPass", "")

  port* = parseInt env.getOrDefault("port", "8080")
  host* = env.getOrDefault("host", "localhost")
  address* = parseUri env.getOrDefault("address", "http://localhost")
  (haveSsl*) = parseAddress address

  appName* = env.getOrDefault("appName", "bible")
  debugging* = env.getOrDefault("debug", true)
  settings* = newSettings(
    appName = appName,
    debug = debugging,
    port = Port port,
    secretKey = env.getOrDefault("secretKey", ""),
    address = host
  )

  errorLog* = env.getOrDefault("errorLog", "error.log")
  rollingLog* = env.getOrDefault("rollingLog", "rolling.log")

  assetsDir* = env.getOrDefault("assetsDir", "assets")

# {.pop.}

template withConf*(body: untyped) =
  ## Dirt trick to bypass gcsafe check, if I use locks, then echo doesn't works
  {.gcsafe.}:
    # withLock confLock:
    body
