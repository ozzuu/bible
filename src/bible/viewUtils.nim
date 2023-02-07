from std/strformat import fmt
from std/strutils import multiReplace, replace, split, toLowerAscii, strip


func getStrongUrl(strong: string): string =
  ## If is a correct strong, returns a a website URL to view it, if strong is
  ## invalid, then a search URL is returned
  let kind = strong[0].toLowerAscii 
  result = "https://biblehub.com/"
  case kind:
  of 'h': result.add "hebrew"
  of 'g': result.add "greek"
  else:
    return fmt"https://ddg.gg/strong {strong}"
  result.add fmt"/strongs_{strong[1..^1]}.htm"

proc parseVerse*(verse: string): string =
  ## Parse the verse fixing XML tags
  var tmp = verse.multiReplace({
    "<pb/>": "",
    " <n>": "<n> ",
    " <S>": "<S> ",
  }).multiReplace({
    "<n>": "<span class=\"explanation\">",
    "</n>": "</span>",
    # "<S>": "<sup class=\"strong\">",
    # "</S>": "</sup>",
  })
  echo tmp
  for part in tmp.split "<S>":
    let parts = part.split "</S>"
    if parts.len == 2:
      let
        strong = parts[0].strip
        url = getStrongUrl strong
      result.add fmt"""<sup class="strong"><a href="{url}" target="_blank" rel="noopener noreferrer">{strong}</a></sup>"""
      result.add parts[1]
    else:
      result.add part

func highlight*(str, text: string): string =
  ## Highlight the `str` by making the `text` bold
  str.replace(text, fmt"<b>{text}</b>")
