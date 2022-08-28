import bible/db

import bible/db/models/[
  book,
  info,
  verse,
  document
]

proc setup*(conn: DbConn) =
  ## Creates all tables
  conn.createTables newVerse()
  conn.createTables newInfo()
  conn.createTables newBook()
  conn.createTables newDocument()
