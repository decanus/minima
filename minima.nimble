# Package

packageName   = "minima"
version       = "0.1.0"
author        = "Dean Eigenmann <dean@eigenmann.me>"
description   = "MinimaDB: An embeddable database written in Nim."
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests"]


# Dependencies

requires "nim >= 1.2.0",
         "stew"

task test, "Run all tests":
  exec "nim c -r --threads:off tests/all_tests"
