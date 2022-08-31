# Package

version       = "1.6.0"
author        = "Thiago Navarro"
description   = "Ozzuu Bible"
license       = "MIT"
srcDir        = "src"
bin           = @["bible"]

binDir = "build"

# Dependencies

requires "nim >= 1.6.4"

# Backend
requires "prologue"
requires "norm"
requires "cligen"

requires "util"

# Frontend
requires "karax"

proc defaultSwitch =
  --opt:speed
  --define:release
  --outDir:build

task buildRelease, "Builds the release version":
  defaultSwitch()
  setCommand "c", "./src/bible"
  
task buildDebug, "Builds the release debug":
  defaultSwitch()
  --define:debug
  setCommand "c", "./src/bible"
