var
  paths = location.pathname.split("/"),
  doc = paths[1] ?? "",
  book = paths[2] ?? "",
  chapter = paths[3] ?? "0",
  verse = paths[4] ?? "0"

if (paths[3] == "search") {
  chapter = "0"
  verse = "0"
  book = `${book}_search_${paths[4]}_${paths[5]}`
} else if (paths[2] == "search") {
  chapter = "0"
  verse = "0"
  book = `bible_search_${paths[3]}_${paths[4]}`
}
