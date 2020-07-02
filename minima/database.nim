# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/results

type 
    ## Database object
    Database* = ref object
        file: string # @TODO: we probably want this somehow else.

    OpenResult* = Result[Database, string] # @TODO use error types instead of string
    GetResult* = Result[seq[byte], string]
    VoidResult* = Result[void, string]

# @TODO: Maybe move this func to ../minima.nim
proc open*(file: string): OpenResult =
    ## Opens a database at the specified path.
    ## This will create a new directory if it does not yet exist.
    discard 

proc close*(db: Database) =
    ## Closes the database.
    discard

proc get*(db: Database, key: seq[byte]): GetResult =
    ## Retrieve a value if it exists. 
    discard

proc set*(db: Database, key: seq[byte], value: seq[byte]): VoidResult =
    ## Set a value for a key.
    discard

proc has*(db: Database, key: seq[byte]): bool =
    ## Check whether a value has been set for a key.
    discard

proc remove*(db: Database, key: seq[byte]): VoidResult =
    ## Remove the set value for a key.
    discard
