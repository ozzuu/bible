# Package

version       = "3.8.0"
author        = "Ozzuu"
description   = "Finally a online bible that respects your privacy!"
license       = "GPL-3.0"
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

from std/strformat import fmt

proc buildCmd(args = "") =
  exec fmt"nimble --passL:-static --passC:-static --opt:speed -d:release {args} build"
  exec fmt"strip {binDir}/{bin[0]}"

task buildRelease, "Builds the release version":
  buildCmd()
  
task buildDebug, "Builds the release debug":
  buildCmd "-d:debug"
