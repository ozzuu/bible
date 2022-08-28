import pkg/prologue

import bible/routes/[
  verse,
  chapter,
  books,
  documents,
]

import bible/routes/default/notFound

type
  Route = tuple
    path: string
    routes: seq[UrlPattern]

const
  routesDefinition*: seq[Route] = @[ ## All application routes
    ("", @[
      pattern("/{doc}/{book}/{chapter}", r_verse, HttpGet, "vesicles"),
      pattern("/{doc}/{book}", r_chapters, HttpGet, "chapters"),
      pattern("/{doc}", r_books, HttpGet, "books"),
      pattern("/", r_documents, HttpGet, "documents"),
    ]),
  ]

  defaultRoutes* = @[ ## Default routes
    (Http404, r_404)
  ]
