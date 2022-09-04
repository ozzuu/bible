import pkg/prologue

import bible/routes/[
  documents,
  books,
  chapters,
  verses,
  compare,
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
      pattern("/compare/{book}/{chapter}/{verse}", r_compare, HttpGet, "compare verse"),
      pattern("/{doc}/{book}/{chapter}", r_verses, HttpGet, "verses"),
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
