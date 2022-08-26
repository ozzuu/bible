from std/uri import Uri, parseUri
from std/strutils import parseInt

import pkg/prologue

func parseAddress(url: Uri): tuple[hasSsl: bool; host: string; port: int] =
  ## Parses the address into `haveSsl`, `host` and `port`
  result.hasSsl = url.scheme == "https"
  result.host = url.hostname
  result.port = if url.port.len == 0: 80 else: parseInt url.port

import std/locks

var confLock*: Lock
initLock confLock

# {.push guard: confLock.} # Why push isn't working?
let
  env = loadPrologueEnv ".env"

  dbHost* = env.getOrDefault("dbHost", ":memory:")
  dbUser* = env.getOrDefault("dbUser", "")
  dbPass* = env.getOrDefault("dbPass", "")

  address* = parseUri env.getOrDefault("address", "http://localhost:8080")
  (haveSsl*, host*, port*) = parseAddress address

  appName* = env.getOrDefault("appName", "bible")
  settings* = newSettings(
    appName = appName,
    debug = env.getOrDefault("debug", true),
    port = Port port,
    secretKey = env.getOrDefault("secretKey", ""),
    address = host
  )

  errorLog* = env.getOrDefault("errorLog", "error.log")
  rollingLog* = env.getOrDefault("rollingLog", "rolling.log")

# {.pop.}

template withConf*(body: untyped) =
  ## Dirt trick to bypass gcsafe check, if I use locks, then echo doesn't works
  {.gcsafe.}:
    # withLock confLock:
    body
