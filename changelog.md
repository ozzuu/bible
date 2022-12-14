# Changelog

## Version 2.2.0 (Sep 11, 2022)

- Fixed access counting

---

## Version 2.1.0 (Sep 5, 2022)

- Show document/book selection in each line
- Added search with pagination
- Added search field to books selection page

---

## Version 2.0.0 (Sep 4, 2022)

- Added comparison page
- Added buttons to compare verse
- Added a function to clean access log

---

## Version 1.9.0 (Sep 2, 2022)

- Added function to `deleteDoc`ument

---

## Version 1.8.0 (Sep 1, 2022)

- Added support to adding bibles that doesn't have the `books_all` table
- Fixed some echo messages in import tools

---

## Version 1.7.0 (Aug 31, 2022)

- Fixed verse number link not clickable
- Added page access counting

---

## Version 1.6.1 (Aug 31, 2022)

- Fixed verses punctuation
- Fixed styles

---

## Version 1.6.0 (Aug 31, 2022)

- Added buttons to go back and forward
  - Fixed buttons position

---

## Version 1.5.0 (Aug 31, 2022)

- Added `example.env`
- Fixed accent books

---

## Version 1.4.0 (Aug 30, 2022)

- Added `update_chapters_quantity` command to update the quantity of chapters
- Renamed `Book.verses` to correct `Book.chapters`

---

## Version 1.3.0 (Aug 30, 2022)

- Done `The book adding needs to be inside verse adding`
- Added what verse/book was added in import

---

## Version 1.2.0 (Aug 29, 2022)

- Separated the port from url at env

---

## Version 1.1.0 (Aug 29, 2022)

- Added status to continue where stopped (import)

---

## Version 1.0.0 (Aug 28, 2022)

- Added documents fetching from DB
- Added books fetching from DB
- Added verses fetching from DB
- Fixed Verse.number saving
- Added complete document name

---

## Version 0.3.0 (Aug 28, 2022)

- Added `Document`s table
- Added the content fetching in home route
- Added views (using karax)
- Added books, chapters and verses routes (dummy data)

---

## Version 0.2.1 (Aug 27, 2022)

- Removed 10 lines db strip in release version

---

## Version 0.2.0 (Aug 26, 2022)

- Added raw DB models
- Added processed models
- Added a subcommand to add a document to the main DB
- Added parsing and merging of one kind of document

---

## Version 0.1.0 (Aug 25, 2022)

- Initialized from [restSPA](https://github.com/thisago/restSpa/)
- Removed user authentication and APIs from template
