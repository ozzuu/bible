# Package

version       = "3.5.1"
author        = "Ozzuu"
description   = "Ozzuu Bible is a online MyBible document reader"
license       = "MIT"
srcDir        = "src"
bin           = @["bible"]

binDir = "build"

# Dependencies

requires "nim >= 1.6.4"

# Backend
requires "prologue"
requires "https://github.com/thisago/norm"# "norm"
requires "cligen"

requires "util"
requires "bibleTools"

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
