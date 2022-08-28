import pkg/prologue

import bible/routes/[
  versicles,
  verses
]

import bible/routes/default/notFound

type
  Route = tuple
    path: string
    routes: seq[UrlPattern]

const
  routesDefinition*: seq[Route] = @[ ## All application routes
    ("", @[
      pattern("/{doc}/{book}/{verse}", r_versicles, HttpGet, "vesicles"),
      pattern("/{doc}/{book}", r_verses, HttpGet, "verses"),
    ]),
  ]

  defaultRoutes* = @[ ## Default routes
    (Http404, r_404)
  ]
