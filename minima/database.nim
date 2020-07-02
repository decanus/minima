# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/results, os, io

type 
    ## Database object
    Database* = ref object
        dir: string # @TODO: we probably want this somehow else.
        log: File

    DatabaseError* = enum
        DirectoryCreationFailed = "minima: failed to create db directory"
        TreeFileCreationFailed  = "minima: failed to create tree file"

# @TODO: Maybe move this func to ../minima.nim
proc open*(dir: string): Result[Database, DatabaseError] =
    ## Opens a database at the specified path.
    ## This will create a new directory if it does not yet exist.
    ##
    ## .. code-block::
    ##
    ## let result = open("/tmp/minima")
    ## if not result.isOk:
    ##     return
    if not os.existsDir(dir):
        try:
            os.createDir(dir)
        except:
            return err(DirectoryCreationFailed)

    var log: File
    try:
        log = open((dir & "/minima.db"), fmReadWrite)
    except:
        return err(TreeFileCreationFailed)

    ok(Database(dir: dir, log: log))

proc close*(db: Database) =
    ## Closes the database.
    discard

proc get*(db: Database, key: seq[byte]): Result[seq[byte], DatabaseError] =
    ## Retrieve a value if it exists. 
    discard

proc set*(db: Database, key: seq[byte], value: seq[byte]): Result[void, DatabaseError] =
    ## Set a value for a key.
    discard

proc has*(db: Database, key: seq[byte]): bool =
    ## Check whether a value has been set for a key.
    discard

proc remove*(db: Database, key: seq[byte]): Result[void, DatabaseError] =
    ## Remove the set value for a key.
    discard
