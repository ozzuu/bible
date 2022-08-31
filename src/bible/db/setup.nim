import bible/db

import bible/db/models/[
  book,
  info,
  verse,
  document,
  access
]

proc setup*(conn: DbConn) =
  ## Creates all tables
  conn.createTables newDocument()
  conn.createTables newInfo()
  conn.createTables newBook()
  conn.createTables newVerse()
  conn.createTables newAccess()
