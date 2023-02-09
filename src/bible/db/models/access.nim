import std/times

import pkg/norm/model

from bible/utils import nowUnix

type
  Access* = ref object of Model
    ## Access counting
    docName*: string
    bookShortName*: string
    chapter*: int
    verse*: int
    time*: int64
    monthlyAccesses*: int
    allAccesses*: int

proc newAccess*(
  docName, bookShortName: string;
  chapter, verse, allAccesses, monthlyAccesses: int;
): Access =
  ## Creates new `Access`
  new result
  result.docName = docName
  result.bookShortName = bookShortName
  result.chapter = chapter
  result.verse = verse
  result.time = nowUnix()
  result.allAccesses = allAccesses
  result.monthlyAccesses = monthlyAccesses

proc newAccess*: Access =
  ## Creates new blank `Access`
  newAccess(
    docName = "",
    bookShortName = "",
    chapter = 0,
    verse = 0,
    allAccesses = 0,
    monthlyAccesses = 0
  )

import bible/db

proc getAccess*(docName, bookShortName: string; chapter: int; verse = 0): Access =
  ## Get the accesses for the page
  result = newAccess()
  try:
    inDb: dbConn.select(
      result,
      "Access.docName = ? and Access.bookShortName = ? and Access.chapter = ? and Access.verse = ?",
      dbValue docName, dbValue bookShortName, dbValue chapter, dbValue verse
    )
  except: discard

proc incAccess*(docName, bookShortName: string; chapter: int; verse = 0) =
  ## Increment the accesses for the page
  var access = getAccess(docName, bookShortName, chapter, verse)
  if access.allAccesses == 0:
    access = newAccess(docName, bookShortName, chapter, verse, 1, 1)
    inDb: dbConn.insert access
  else:
    block:
      let nowTime = now()
      if $($nowTime.utc)[8..9] == "01":
        if fromUnix(access.time) + 1.months < nowTime.toTime:
          access.time = nowUnix()
          access.monthlyAccesses = 1
          break
      inc access.allAccesses
      inc access.monthlyAccesses
    inDb: dbConn.update access
