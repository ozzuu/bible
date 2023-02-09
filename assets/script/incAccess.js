;(async () => {
  await fetch("/api/incAccess", {
    method: "post",
    body: JSON.stringify({
      "doc": decodeURIComponent(doc),
      "book": decodeURIComponent(book),
      "chapter": chapter,
      "verse": verse,
    }),
    headers: {
      "Content-type": "application/json"
    }
  })
})()
