from std/strformat import fmt
from std/strutils import multiReplace, replace

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

func highlight*(str, text: string): string =
  ## Highlight the `str` by making the `text` bold
  str.replace(text, fmt"<b>{text}</b>")
