(async () => {
  const
    paths = location.pathname.split("/"),
    doc = paths[1] ?? ""
    book = paths[2] ?? ""
    chapter = paths[3] ?? ""
  await fetch("/api/incAccess", {
    method: "post",
    body: JSON.stringify({
      "doc": doc,
      "book": book,
      "chapter": chapter
    }),
    headers: {
      "Content-type": "application/json"
    }
  })
})()
