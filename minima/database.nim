## Minima
##
## Copyright (c) 2020 Dean Eigenmann
## Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

type 
    ## Database object
    Database* = ref object

proc get*(db: Database, key: seq[byte]): seq[byte] =
    discard

proc set*(db: Database, key: seq[byte], value: seq[byte]) =
    discard

proc has*(db: Database, key: seq[byte]): bool =
    discard

proc remove*(db: Database, key: seq[byte], value: seq[byte]) =
    discard
