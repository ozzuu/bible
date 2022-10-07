from std/uri import Uri, parseUri
from std/strutils import parseInt

import pkg/prologue

const logicInApi* = false

const
  ifContainsAllErr* = "Please provide $1"
  ifContainsAtLeastErr* = "Please provide at least $1"
  ifContainsInvalidReq* = "Invalid request"

const bookVariations* = [
  @["Gn", "Gen"], 
  @["Êx", "Ex", "Exo"], 
  @["Lv", "Lev"], 
  @["Nm", "Num"], 
  @["Dt", "Deu", "Deut"], 
  @["Js", "Jos", "Josh"], 
  @["Jz", "Jdg", "Judg"], 
  @["Rt", "Ru", "Ruth", "RUT"], 
  @["1Sm", "1 Sm", "1Sam", "1SA", "1 Sam"], 
  @["2Sm", "2 Sm", "2Sam", "2SA", "2 Sam"], 
  @["1Rs", "1 Rs", "1Kg", "1Kin", "1 Kin", "1KI", "1Kgs"], 
  @["2Rs", "2 Rs", "2Kg", "2Kin", "2 Kin", "2KI", "2Kgs"], 
  @["1Cr", "1 Cr", "1Ch", "1Chr", "1 Chr", "1CH"], 
  @["2Cr", "2 Cr", "2Ch", "2Chr", "2 Chr", "2CH"], 
  @["Ed", "Esd", "Ezr", "Ezra"], 
  @["Ne", "Neh"], 

  # apocrypha
  @["1Esd", "1 Esd", "3ES"], 
  @["Tob"], 
  @["Judi", "Judith", "JDT"], 

  # non apocrypha
  @["Et", "Est", "Esth"], 

  # apocrypha
  @["Esth Gr", "ESG"], 

  # non apocrypha
  @["Jó", "Jb", "Job"], 
  @["Sl", "Ps", "PSA"], 
  @["Pv", "Pr", "Prov", "PRO"], 
  @["Ec", "Eccl", "ECC", "Eccles", "Ecl"], 

  # apocrypha
  @["Wis", "Sb"],
  @["Eclo", "Sir", "Ecclus"],

  # non apocrypha
  @["Ct", "Sg", "Song", "SNG"], 
  @["Is", "ISA"], 
  @["Jr", "Jer"], 
  @["Lm", "Lam"], 

  # apocrypha
  @["Epi"], 
  @["Bar"], 
  @["Sus"], 

  # non apocrypha
  @["Ez", "Ezk", "Ezek"], 
  @["Dn", "Dan"], 
  
  # apocrypha
  @["Bel"], 

  # non apocrypha
  @["Os", "Hs", "Hos"], 
  @["Jl", "Joel", "JOL"], 
  @["Am", "AMO", "Amos"], 
  @["Ob", "Obad", "OBA", "Ab"], 
  @["Jn", "Jnh", "JON", "Jonah", "Jona"], 
  @["Mq", "Mc", "Mic"], 
  @["Na", "Nah", "NAM"], 
  @["Hc", "Hab"], 
  @["Sf", "Zph", "ZEP", "Zeph"], 
  @["Ag", "Hg", "Hag"], 
  @["Zc", "Zch", "ZEC", "Zech"], 
  @["Ml", "Mal"], 
  @["Mt", "Mat"], 
  @["Mc", "Mk", "Mark"], 
  @["Lc", "Lk", "LUK", "Luke"], 
  @["Jo", "Jn"], # FIX ACCENT
  @["At", "Ac", "Acts", "ACT"], 
  @["Rm", "ROM"], 
  @["1Co", "1 Co", "1Cor", "1 Cor"], 
  @["2Co", "2 Co", "2Cor", "2 Cor"], 
  @["Gl", "Gal"], 
  @["Ef", "Eph"], 
  @["Fp", "Php", "Phil", "Fl"], 
  @["Cl", "Col"], 
  @["1Ts", "1 Ts", "1Th", "1Ths", "1 Thes"], 
  @["2Ts", "2 Ts", "2Th", "2Ths", "2 Thes"], 
  @["1Tm", "1 Tm", "1 Tim", "1TI", "1Tim"], 
  @["2Tm", "2 Tm", "2 Tim", "1TI", "2Tim"], 
  @["Tt", "Ti", "Tit", "Titus"], 
  @["Fm", "Phm", "Phlm", "Philem"], 
  @["Hb", "Heb"], 
  @["Tg", "Jms", "James", "Jas", "Jam"], 
  @["1Pe", "1 Pe", "1Pt", "1Pet", "1Pd", "1 Pet"], 
  @["2Pe", "2 Pe", "2Pt", "2Pet", "2Pd", "2 Pet"], 
  @["1Jo", "1 Jo", "1Jn", "1 John"], 
  @["2Jo", "2 Jo", "2Jn", "2 John"], 
  @["3Jo", "3 Jo", "3Jn", "3 John"], 
  @["Jd", "Jude", "Jud"],
  @["Ap", "Rv", "Rev"],
  @["MAN", "PrMan"],


  # apocrypha
  @["1MA", "1Mac", "1Mc", "1Mb"],
  @["2MA", "2Mac", "2Mc", "2Mb"],
]

const itemsPerPage* = 10

func parseAddress(url: Uri): tuple[hasSsl: bool] =
  ## Parses the address into `haveSsl`, `host`
  result.hasSsl = url.scheme == "https"


# import std/locks
# var confLock*: Lock
# initLock confLock

# {.push guard: confLock.} # Why push isn't working?
let
  env = loadPrologueEnv ".env"

  dbHost* = env.getOrDefault("dbHost", ":memory:")
  dbUser* = env.getOrDefault("dbUser", "")
  dbPass* = env.getOrDefault("dbPass", "")

  port* = parseInt env.getOrDefault("port", "8080")
  host* = env.getOrDefault("host", "localhost")
  address* = parseUri env.getOrDefault("address", "http://localhost")
  (haveSsl*) = parseAddress address

  appName* = env.getOrDefault("appName", "bible")
  debugging* = env.getOrDefault("debug", true)
  settings* = newSettings(
    appName = appName,
    debug = debugging,
    port = Port port,
    secretKey = env.getOrDefault("secretKey", ""),
    address = host
  )

  errorLog* = env.getOrDefault("errorLog", "error.log")
  rollingLog* = env.getOrDefault("rollingLog", "rolling.log")

  assetsDir* = env.getOrDefault("assetsDir", "assets")

# {.pop.}

template withConf*(body: untyped) =
  ## Dirt trick to bypass gcsafe check, if I use locks, then echo doesn't works
  {.gcsafe.}:
    # withLock confLock:
    body
