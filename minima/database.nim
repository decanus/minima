# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/results, os

type 
    ## Database object
    Database* = ref object
        dir: string # @TODO: we probably want this somehow else.

    DatabaseError* = enum
        DirectoryCreationFailed = "failed to create db directory"

    DatabaseResult*[T] = Result[T, DatabaseError]

# @TODO: Maybe move this func to ../minima.nim
proc open*(dir: string): DatabaseResult[DatabaseResult] =
    ## Opens a database at the specified path.
    ## This will create a new directory if it does not yet exist.
    
    if not os.existsDir(dir):
        try:
            os.createDir(dir)
        except:
            return err(DirectoryCreationFailed)

    var db: Database

    discard 

proc close*(db: Database) =
    ## Closes the database.
    discard

proc get*(db: Database, key: seq[byte]): DatabaseResult[seq[byte]] =
    ## Retrieve a value if it exists. 
    discard

proc set*(db: Database, key: seq[byte], value: seq[byte]): DatabaseResult[void] =
    ## Set a value for a key.
    discard

proc has*(db: Database, key: seq[byte]): bool =
    ## Check whether a value has been set for a key.
    discard

proc remove*(db: Database, key: seq[byte]): DatabaseResult[void] =
    ## Remove the set value for a key.
    discard
