# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

type 
    ## Database object
    Database* = ref object

proc open*(file: string): Database =
    ## Opens a database at the specified path.
    ## This will create a new directory if it does not yet exist.
    discard 

proc get*(db: Database, key: seq[byte]): seq[byte] =
    discard

proc set*(db: Database, key: seq[byte], value: seq[byte]) =
    discard

proc has*(db: Database, key: seq[byte]): bool =
    discard

proc remove*(db: Database, key: seq[byte], value: seq[byte]) =
    discard
