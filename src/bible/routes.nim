import pkg/prologue

import bible/routes/[
  documents,
  books,
  chapters,
  verses,
  compare,
  search,
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
      pattern("/{doc}/search/{query}/{page}", r_search, HttpGet, "search_verses"),
      pattern("/compare/{book}/{chapter}/{verse}", r_compare, HttpGet, "compare_verse"),
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
