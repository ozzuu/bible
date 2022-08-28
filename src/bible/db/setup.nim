import bible/db

import bible/db/models/[
  book,
  info,
  verse,
  document
]

proc setup*(conn: DbConn) =
  ## Creates all tables
  conn.createTables newBook()
  conn.createTables newInfo()
  conn.createTables newVerse()
  conn.createTables newDocument()
