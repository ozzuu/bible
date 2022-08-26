import pkg/prologue

import bible/routes/home

import bible/routes/default/notFound

type
  Route = tuple
    path: string
    routes: seq[UrlPattern]

const
  routesDefinition*: seq[Route] = @[ ## All application routes
    ("", @[
      pattern("/{doc}/{book}/{verse}", r_home, HttpGet, "home"),
    ]),
  ]

  defaultRoutes* = @[ ## Default routes
    (Http404, r_404)
  ]
