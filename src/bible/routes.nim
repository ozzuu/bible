import pkg/prologue

import bible/routes/[
  documents,
  books,
  chapters,
  verses,
]
import bible/routes/api/incAccess

import bible/routes/default/notFound

type
  Route = tuple
    path: string
    routes: seq[UrlPattern]

const
  routesDefinition*: seq[Route] = @[ ## All application routes
    ("", @[
      pattern("/{doc}/{book}/{chapter}", r_verses, HttpGet, "veses"),
      pattern("/{doc}/{book}", r_chapters, HttpGet, "chapters"),
      pattern("/{doc}", r_books, HttpGet, "books"),
      pattern("/", r_documents, HttpGet, "documents"),
    ]),
    ("api", @[
      pattern("/incAccess", r_incAccess, HttpPost, "incAccess"),
    ]),
  ]

  defaultRoutes* = @[ ## Default routes
    (Http404, r_404)
  ]
