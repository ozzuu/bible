const
  paths = location.pathname.split("/"),
  doc = paths[1] ?? "",
  book = paths[2] ?? "",
  chapter = paths[3] ?? "",
  verse = paths[4] ?? "0"

;(async () => {
  await fetch("/api/incAccess", {
    method: "post",
    body: JSON.stringify({
      "doc": doc,
      "book": book,
      "chapter": chapter,
      "verse": verse,
    }),
    headers: {
      "Content-type": "application/json"
    }
  })
})()
