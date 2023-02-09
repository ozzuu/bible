const
  paths = location.pathname.split("/"),
  doc = paths[1] ?? "",
  book = paths[2] ?? "",
  chapter = paths[3] ?? "",
  verse = paths[4] ?? "0"
