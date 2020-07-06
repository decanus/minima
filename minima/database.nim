# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/[results, byteutils, endians2], os, tree, sequtils, tables, sets

type 
    ## Database object
    Database* = ref object
        dir: string # @TODO: we probably want this somehow else.
        log: File
        tree: BTree[string, seq[byte]]

        tags: Table[string, HashSet[seq[byte]]]

    DatabaseError* = enum
        DirectoryCreationFailed = "minima: failed to create db directory"
        TreeFileCreationFailed  = "minima: failed to create tree file"
        KeyNotFound             = "minima: key not found"
        PersistenceFailed       = "minima: persistence failed"

proc log(db: Database, key: seq[byte], value: seq[byte]) =
    let write = concat(
        @(uint32(len(key)).toBytes),
        @(uint32(len(value)).toBytes),
        key,
        value
    )

    # @TODO CATCH EXCEPTIONS
    discard db.log.writeBytes(write, 0, len(write))
    db.log.flushFile()

proc readInt(file: File): int =
    var arr: array[4, byte]
    discard file.readBytes(arr, 0, 4)

    return int(uint32.fromBytes(arr))

proc recover(db: Database) =
    while db.log.getFilePos() <= db.log.getFileSize() - 1:
        var keyLen = readInt(db.log)
        var valLen = readInt(db.log)

        # @TODO CATCH EXCEPTIONS

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
    ## **Example:**
    ##
    ## .. code-block::
    ##   let result = open("/tmp/minima")
    ##   if not result.isOk:
    ##     return
    if not os.existsDir(dir):
        try:
            os.createDir(dir)
        except:
            return err(DirectoryCreationFailed)

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

    ok(db)

proc close*(db: Database) =
    ## Closes the database.
    db.log.close()

proc get*(db: Database, key: seq[byte]): Result[seq[byte], DatabaseError] =
    ## Retrieve a value if it exists.
    ## 
    ## **Example:**
    ## 
    ## .. code-block::
    ##   let key = @[byte 1, 2, 3, 4]
    ##   let value = @[byte 4, 3, 2, 1]
    ##   db.set(key, value)
    ##   assert(db.get(key) == value)
    let val = db.tree.getOrDefault(string.fromBytes(key))
    if val.len == 0:
        return err(KeyNotFound)

    ok(val)

proc set*(db: Database, key: seq[byte], value: seq[byte]): Result[void, DatabaseError] =
    ## Set a value for a key.
    ## 
    ## **Example:**
    ## 
    ## .. code-block::
    ##   let key = @[byte 1, 2, 3, 4]
    ##   let value = @[byte 4, 3, 2, 1]
    ##   db.set(key, value)
    ##   assert(db.get(key) == value)
    db.tree.add(string.fromBytes(key), value)

    try:
        log(db, key, value)
    except:
        return err(PersistenceFailed)
    
    ok()

proc has*(db: Database, key: seq[byte]): bool =
    ## Check whether a value has been set for a key.
    ## 
    ## **Example:**
    ## 
    ## .. code-block::
    ##   let key = @[byte 1, 2, 3, 4]
    ##   db.set(key, @[byte 4, 3, 2, 1]])
    ##   assert(db.has(key))
    db.tree.contains(string.fromBytes(key))

proc tag*(db: Database, key: seq[byte], tag: seq[byte]) =
    ## Adds a tag to a specific key.
    ##
    ## Example:
    ##
    ## .. code-block::
    ##   let key = @[byte 1, 2, 3, 4]
    ##   db.set(key, @[byte 1, 2, 3, 4, 5])
    ##   db.tag(key, @[byte 1, 2, 3])
    let t = string.fromBytes(tag)
    discard db.tags.hasKeyOrPut(t, initHashSet[seq[byte]]())

    # @TODO, Tag incl must be logged

    db.tags[t].incl(key)

proc tags*(db: Database): seq[seq[byte]] =
    ## Returns all the tags currently stored in the database.
    discard

iterator filter*(db: Database, tag: seq[byte]): (seq[byte], seq[byte]) =
    ## Returns all K, V pairs that have been tagged.
    discard

iterator intersection*(db: Database, tags: seq[seq[byte]]): (seq[byte], seq[byte]) =
    ## Returns all K, V pairs that are in the intersection of the passed tags.
    discard

iterator union*(db: Database, tags: seq[seq[byte]]): (seq[byte], seq[byte]) =
    ## Returns all K, V pairs that are the union of the passed tags.
    discard
