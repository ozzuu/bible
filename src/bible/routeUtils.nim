from std/logging import nil
from std/json import parseJson, `{}=`, `%`, newJObject
from std/strtabs import keys
from std/uri import decodeUrl

const
  autoFormParsing {.boolDefine.} = true
  autoXmlParsing {.boolDefine.} = false # not implemented

when autoXmlParsing:
  from std/xmlparser import parseXml
  import std/xmltree

import bible/config
export config
import bible/utils
export utils

import pkg/prologue
export json


proc hasKey*(session: var Session; key: string): bool =
  ## Check if session have specific session
  try:
    discard session[key]
    return true
  except:
    return false

using
  ctx: Context
  node: JsonNode
  body: untyped

proc setContentJsonHeader*(ctx) =
  ## Set the response content-type to json
  ctx.response.setHeader "content-type", "application/json"

template withParams*(ctx; get = false; path = false; bodyCode: untyped) =
  ## Run `body` if request has a JSON body
  ##
  ## If no JSON sent or/and the `content-type` is not
  ## JSON, it will response with `Http400` and close
  ## connection
  ##
  ## Use `get` to merge the get parameters into `node`
  ## The GET parameters override the POST
  let reqMethod = ctx.request.reqMethod
  var
    node {.inject.} = newJObject()
    error {.inject.} = true

  if reqMethod == HttpPost:
    case ctx.request.contentType:
    of "application/json":
      try:
        node = parseJson ctx.request.body
        error = false
      except JsonParsingError: discard
    of "application/x-www-form-urlencoded", "multipart/form-data":
      when autoFormParsing:
        for key, val in ctx.request.formParams.data:
          # echo val.params
          node{key} = %val.body
        error = false
    of "application/xml":
      when autoXmlParsing:
        {.fatal: "XML parsing not implemented".}
    else: discard
  else:
    error = false
  if get or reqMethod == HttpGet:
    for key, val in ctx.request.queryParams:
      node{key} = %decodeUrl val
  if path:
    for key, val in ctx.request.pathParams:
      node{key} = %decodeUrl val
  logging.debug "Auto parsed params: " & $node
  bodyCode

type
  ResponseJson* = object
    kind*: ResponseKind
    text*: string
    error*: bool
  ResponseKind* = enum
    RkMessage = "message",
    RkJson = "json"

func initResponseJson(
  kind: ResponseJson.kind;
  text: ResponseJson.text;
  error: ResponseJson.error
): ResponseJson =
  ResponseJson(kind: kind, text: text, error: error)

template respJson*(data: untyped; code: HttpCode) =
  ## Send a JSON to client
  when logicInApi:
    resp($(%*data), code)
  else:
    resp(data.text, code)

template respErr*(msg: string; code = Http400) =
  ## Send a error message in a JSON to client
  respJson(initResponseJson(RkMessage, msg, true), code)
template respSuc*(msg: string; code = Http200) =
  ## Send a success message in a JSON to client
  respJson(initResponseJson(RkMessage, msg, false), code)
template respErrJson*(json: string; code = Http400) =
  ## Send a success message in a JSON to client
  respJson(initResponseJson(RkJson, json, true), code)
template respSucJson*(json: string; code = Http200) =
  ## Send a error message in a JSON to client
  respJson(initResponseJson(RkJson, json, false), code)

from std/strutils import `%`, join

template ifNoError(body) =
  ## If `error` is false execute the body, else shows a error
  if not error: body
  else: respErr ifContainsInvalidReq

template ifContains*(
  node;
  all: openArray[string];
  body
) =
  ## Checks if the json have errors and `all` fields, if not exists,
  ## send the error message and not executes the body
  ifNoError:
    var havent = @all
    for field in all:
      if node.hasKey field:
        havent.delete havent.find field
    if havent.len > 0:
      respErr ifContainsAllErr % havent.join ", "
    else:
      body

template ifContains*(
  node;
  atLeast: openArray[string];
  body
) =
  ## Checks if the json have errors and `atLeast` fields, if not exists,
  ## send the error message and not executes the body
  ifNoError:
    if atLeast.len > 0:
      var have = false
      for field in atLeast:
        if node.hasKey field:
          have = true
      if have:
        body
      else:
        respErr ifContainsAtLeastErr % atLeast.join ", "


template forceHttpMethod*(ctx; httpMethod: HttpMethod) =
  ## Forces an specific HTTP method
  ##
  ## Useful just in development
  assert ctx.request.reqMethod == httpMethod

when not defined(windows):
  from pkg/httpx import ip
proc ip*(req: Request): string =
  ## Get ip from request
  when not defined windows:
    result = req.nativeRequest.ip
  else:
    result = req.nativeRequest.hostname

from std/json import getStr, getBool, getInt, getFloat

proc updateFields*(
  obj: var object;
  node: JsonNode;
  blacklist: openArray[string] = [];
): bool =
  ## Updates the object by node items (if exists)
  result = false
  for key, value in obj.fieldPairs:
    if key notin blacklist:
      if node.hasKey key:
        let val = node{key}
        when value is bool: value = val.getBool
        elif value is SomeFloat: value = val.getFloat
        elif value is SomeInteger: value = val.getInt
        elif value is string: value = val.getStr
        if not result:
          result = true

type
  ReqDbField = tuple
    ## Request/DB fields relation
    req, db: string
  ReqDbFields = openArray[ReqDbField]

proc getUsing*(
  table: type;
  fields: ReqDbFields;
  node
): auto =
  ## Gets a `table` row using some of the provided `fields` in the `node`
  for (field, inDb) in fields:
    if node.hasKey field:
      let val = node{field}.getStr
      result = table.get(val, [inDb])
      break

import bible/views/error/[
  docNotExists,
  bookNotExists,
  chapterNotExists,
]
from bible/db/models/document import getAllDocsShortNames

template withDoc*(ctx; doc: string; body: untyped): untyped =
  ## Check if the document exists
  if doc in getAllDocsShortNames():
    body
  else:
    ctx.render docNotExists doc

template withBook*(ctx; book: string; chapters: int; body: untyped): untyped =
  ## Check if the book exists
  if chapters > 0:
    body
  else:
    ctx.render bookNotExists book

template withChapter*(ctx; chapter, verses: int; body: untyped): untyped =
  ## Check if the chapter exists
  if verses > 0:
    body
  else:
    ctx.render chapterNotExists chapter
