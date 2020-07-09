# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## This module implements Minima's basic key value database.

import stew/[results, byteutils], os, tree, log, nimcrypto

type 
    ## Database object
    Database* = ref object
        dir: string # @TODO: we probably want this somehow else.
        log: Log
        tree: BTree[string, seq[byte]]

    DatabaseError* = enum
        DirectoryCreationFailed = "minima: failed to create db directory"
        TreeFileCreationFailed  = "minima: failed to create tree file"
        KeyNotFound             = "minima: key not found"
        PersistenceFailed       = "minima: persistence failed"

proc toAESKey*(str: string): array[aes256.sizeKey, byte] =
    ## Concerts a string to an AES Key for opening an encrypted database.
    ## 
    ## **Example::**
    ## .. code-block::
    ##   let password = "foo".toAESKey
    var pass = str
    var key: array[32, byte]
    copyMem(addr key[0], addr pass[0], len(pass))

    return key

proc open*(dir: string, key: array[aes256.sizeKey, byte]): Result[Database, DatabaseError] =
    ## Opens an encrypted database at the specified path.
    ## 
    ## **Example:**
    ##
    ## .. code-block::
    ##   let result = open("/tmp/minima", "password".toAESKey)
    ##   if not result.isOk:
    ##     return
    try:
        os.createDir(dir)
    except:
        return err(DirectoryCreationFailed)

    var path = dir / "minima.db"
    var mode = fmReadWrite
    if fileExists(path):
        mode = fmReadWriteExisting

    var f: File
    try:
        f = open(path, mode)
    except:
        return err(TreeFileCreationFailed)

    var db = Database(
        dir: dir,
        log: EncryptedLog.init(f, key),
        tree: initBTree[string, seq[byte]]()
    )

    if mode == fmReadWriteExisting:
        for (key, val) in db.log.pairs():
            db.tree.add(string.fromBytes(key), val)

    ok(db)

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
    try:
        os.createDir(dir)
    except:
        return err(DirectoryCreationFailed)

    var path = dir / "minima.db"
    var mode = fmReadWrite
    if fileExists(path):
        mode = fmReadWriteExisting

    var f: File
    try:
        f = open(path, mode)
    except:
        return err(TreeFileCreationFailed)

    var db = Database(
        dir: dir,
        log: StandardLog.init(f),
        tree: initBTree[string, seq[byte]]()
    )

    if mode == fmReadWriteExisting:
        for (key, val) in db.log.pairs():
            db.tree.add(string.fromBytes(key), val)

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
        db.log.log(key, value)
    except:
        echo repr(getCurrentException())
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
