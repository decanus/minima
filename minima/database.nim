# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/[results, byteutils, endians2], os, tree, sequtils

type 
    ## Database object
    Database* = ref object
        dir: string # @TODO: we probably want this somehow else.
        log: File
        tree: BTree[string, seq[byte]]

    DatabaseError* = enum
        DirectoryCreationFailed = "minima: failed to create db directory"
        TreeFileCreationFailed  = "minima: failed to create tree file"
        KeyNotFound             = "minima: key not found"

proc log(db: Database, key: seq[byte], value: seq[byte]) =
    # @TODO WE WILL PROBABLY WANNA FIX THIS TO NOT DISCARD SHIT
    # @TODO THIS SHIT IS NOT PRETTY

    let write = concat(
        @(uint32(len(key).toU32).toBytes),
        @(uint32(len(value).toU32).toBytes),
        key,
        value
    )

    discard db.log.writeBytes(write, 0, len(write))
    db.log.flushFile()

proc recover(db: Database) =
    while db.log.getFilePos() <= db.log.getFileSize() - 1:
        var keyLenArr: array[4, byte]
        discard db.log.readBytes(keyLenArr, 0, 4)

        var valueLenArr: array[4, byte]
        discard db.log.readBytes(valueLenArr, 0, 4)

        let keyLen = int(uint32.fromBytes(keyLenArr))
        let valLen = int(uint32.fromBytes(valueLenArr))

        var key = newSeq[byte](keyLen)
        discard db.log.readBytes(key, 0, keyLen)

        var val = newSeq[byte](valLen)
        discard db.log.readBytes(val, 0, valLen)

        db.tree.add(string.fromBytes(key), val)

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

    # @TODO we need to check if the file exists
    var path = dir & "/minima.db"
    var mode = fmReadWrite
    if fileExists(path):
        mode = fmReadWriteExisting

    var log: File
    try:
        log = open(path, mode)
    except:
        return err(TreeFileCreationFailed)

    var db = Database(
        dir: dir,
        log: log,
        tree: initBTree[string, seq[byte]]()
    )

    if mode == fmReadWriteExisting:
        recover(db)
        #db.log.setFilePos(log.getFileSize() - 1)

    ok(db)

proc close*(db: Database) =
    ## Closes the database.
    db.log.close()

proc get*(db: Database, key: seq[byte]): Result[seq[byte], DatabaseError] =
    ## Retrieve a value if it exists.
    ## .. code-block::
    ##
    ## let key = [byte 1, 2, 3, 4]
    ## let value = [byte 4, 3, 2, 1]
    ## db.set(key, value)
    ## assert(db.get(key) == value)
    let val = db.tree.getOrDefault(string.fromBytes(key))
    if val.len == 0:
        return err(KeyNotFound)

    ok(val)

proc set*(db: Database, key: seq[byte], value: seq[byte]): Result[void, DatabaseError] =
    ## Set a value for a key.
    ## .. code-block::
    ##
    ## let key = [byte 1, 2, 3, 4]
    ## let value = [byte 4, 3, 2, 1]
    ## db.set(key, value)
    ## assert(db.get(key) == value)
    db.tree.add(string.fromBytes(key), value)
    log(db, key, value)
    ok()

proc has*(db: Database, key: seq[byte]): bool =
    ## Check whether a value has been set for a key.
    ## .. code-block::
    ##
    ## let key = [byte 1, 2, 3, 4]
    ## db.set(key, [byte 4, 3, 2, 1]])
    ## assert(db.has(key))
    db.tree.contains(string.fromBytes(key))
