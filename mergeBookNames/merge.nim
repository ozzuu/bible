import std/[
  json,
  os,
  sequtils,
  strformat,
  uri
]

var books: seq[seq[string]]

for f in commandLineParams():
  let node = parseJson readFile f
  if books.len == 0:
    books = newSeqWith(node.len, newSeq[string]())
  elif books.len != node.len:
    echo fmt"Skipping {f}, the size is {node.len}, but the correct is {books.len}"
    continue
  var i = 0
  for book in node:
    let name = decodeUrl book.getStr
    if name notin books[i]:
      books[i].add name
    inc i

echo books
# "all.jsonc".writeFile $(%*books)
