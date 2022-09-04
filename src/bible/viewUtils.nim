from std/strutils import multiReplace, join

proc parseVerse*(verse: string): string =
  ## Parse the verse fixing XML tags
  verse.multiReplace({
    "<pb/>": "",
    " <n>": "<n> ",
    " <S>": "<S> ",
  }).multiReplace({
    "<n>": "<span class=\"explanation\">",
    "</n>": "</span>",
    "<S>": "<sup class=\"strong\">",
    "</S>": "</sup>",
  })
