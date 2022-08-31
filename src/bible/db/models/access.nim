import std/times

import pkg/norm/model

from bible/utils import nowUnix

type
  Access* = ref object of Model
    ## Access counting
    docName*: string
    bookShortName*: string
    chapter*: int
    time*: int64
    accesses*: int
    

proc newAccess*(
  docName, bookShortName: string;
  chapter, accesses: int;
): Access =
  ## Creates new `Access`
  new result
  result.docName = docName
  result.bookShortName = bookShortName
  result.chapter = chapter
  result.time = nowUnix()
  result.accesses = accesses

proc newAccess*: Access =
  ## Creates new blank `Access`
  newAccess(
    docName = "",
    bookShortName = "",
    chapter = 0,
    accesses = 0
  )

import bible/db

proc getAccess*(docName, bookShortName: string; chapter: int): Access =
  ## Get the accesses for the page
  result = newAccess()
  try:
    inDb: dbConn.select(
      result,
      "Access.docName = ? and Access.bookShortName = ? and Access.chapter = ?",
      dbValue docName, dbValue bookShortName, dbValue chapter
    )
  except: discard

proc incAccess*(docName, bookShortName: string; chapter: int) =
  ## Increment the accesses for the page
  var access = getAccess(docName, bookShortName, chapter)
  if access.accesses == 0:
    access = newAccess(docName, bookShortName, chapter, 1)
    inDb: dbConn.insert access
  else:
    if fromUnix(access.time) + 1.months < now().toTime:
      access.time = nowUnix()
      access.accesses = 1
    else:
      inc access.accesses
    inDb: dbConn.update access
