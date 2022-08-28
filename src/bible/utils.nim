from std/strformat import fmt
from std/times import getTime, toUnix
from std/json import JsonNode, keys, delete
import bible/config

proc nowUnix*: int64 =
  ## Returns the unix time of now
  getTime().toUnix

from std/uri import `$`
from bible/config import address

proc url*(path: string): string =
  withConf:
    var link = address
    link.path = path
    result = $link

proc assetUrl*(path: string): string =
  withConf:
    result = url fmt"/{assetsDir}/{path}"
