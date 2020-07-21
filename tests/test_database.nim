import unittest

import ../minima/[database, tree], stew/[results, byteutils, endians2], os, sequtils

type
    InitProc = proc (): Database

const DatabasePath = "/tmp"

proc checkValues(db: Database, vals: seq[seq[byte]]): bool =
    for val in vals:
        var res = db.get(val)
        if not res.isOk or res.value != val:
            return false

    return true

proc createEncryptedDatabase(): Database =
    var res = database.open(DatabasePath, "password".toAESKey)
    check:
        res.isOk 
    
    return res.value

proc createDatabase(): Database =
    var res = database.open(DatabasePath)
    check:
        res.isOk 
    
    return res.value

proc testSetAndGet(fn: InitProc) =
    let key = @[byte 1, 2, 3, 4]
    let value = @[byte 4, 3, 2, 1]
        
    let db = fn()
    let setResult = db.set(key, value)
    check:
        setResult.isOk

    let getResult = db.get(key)

    check:
        getResult.isOk
        getResult.value == value

proc testHasReturnsExpectedValue(fn: InitProc) =
        let db = fn()

        let key = @[byte 1, 2, 3, 4, 5]
        check:
            not db.has(key)

        discard db.set(key, key)
        check:
            db.has(key)

proc testRecoverWorks(fn: InitProc) =
    var db = fn()
    
    let vals = @[@[byte 1, 2, 3, 4], @[byte 1, 2, 3, 4, 5], @[byte 1, 2, 3, 4, 5, 6]]

    for val in vals:
        discard db.set(val, val)

    db.close()
    
    db = fn()

    check:
        checkValues(db, vals)

proc testWriteToRecoveredFile(fn: InitProc) =
    var db = fn()
    let vals = @[@[byte 1, 2, 3, 4], @[byte 1, 2, 3, 4, 5], @[byte 1, 2, 3, 4, 5, 6]]

    for val in vals:
        discard db.set(val, val)

    db.close()

    db = fn()

    check:
        checkValues(db, vals)

    let newVals = @[@[byte 1, 2, 3, 4, 5, 6, 7], @[byte 1, 2, 3, 4, 5, 6, 7, 8]]
    for val in newVals:
        discard db.set(val, val)
        
    db.close()

    db = fn()

    check:
        checkValues(db, vals)
        checkValues(db, newVals)

proc testCanOverWriteValues(fn: InitProc) =
    let db = fn()
    let key = @[byte 1, 2, 3, 4]

    discard db.set(key, key)

    check:
        db.has(key)

    discard db.set(key, @[byte 1, 2])

    var res = db.get(key)
    check:
        res.value == @[byte 1, 2]

proc testRange(fn: InitProc) =
    let db = fn()
    
    var i = 0
    while i <= M*3:
        let b = @(uint64(i).toBytes)
        discard db.set(b, b)
        inc(i)

    let 
        first = M - 5
        last = M + 3
        firstKey = @(uint64(first).toBytes)
        lastKey = @(uint64(last).toBytes)
        diff = last - first

    var c = 0
    for v in db.range(firstKey, lastKey):
        echo uint64.fromBytes(v)
        check:
            v == @(uint64(first + c).toBytes())
        inc(c)

    check:
        c == diff

proc testSetAndGetMany(fn: InitProc) =
    let db = fn()

    var i = 0
    while i <= M*3:
        let b = @(uint64(i).toBytes)
        var res = db.set(b, b)
        check:
            res.isOk

        inc(i)

    i = 0
    while i <= M*3:
        let b = @(uint64(i).toBytes)
        var res = db.get(b)
        check:
            res.isOk
            res.value == b

        inc(i)
 
suite "Encrypted Database Test Suite":
    teardown:
        removeFile(DatabasePath & "/minima.db")

    test "can set and get key":
        testSetAndGet(createEncryptedDatabase)

    test "has returns expected value":
        testHasReturnsExpectedValue(createEncryptedDatabase)

    test "recover works":
        testRecoverWorks(createEncryptedDatabase)

    test "writes correctly to recovered file":
        testWriteToRecoveredFile(createEncryptedDatabase)

    test "can overwrite values":
        testCanOverWriteValues(createEncryptedDatabase)

    test "range returns correct values":
        testRange(createEncryptedDatabase)

    test "set and get many":
        testSetAndGetMany(createEncryptedDatabase)

suite "Database Test Suite":
    teardown:
        removeFile("/tmp/minima.db")

    test "can set and get key":
        testSetAndGet(createDatabase)

    test "has returns expected value":
        testHasReturnsExpectedValue(createDatabase)

    test "recover works":
        testRecoverWorks(createDatabase)

    test "writes correctly to recovered file":
        testWriteToRecoveredFile(createDatabase)

    test "can overwrite values":
        testCanOverWriteValues(createDatabase)

    test "range returns correct values":
        testRange(createDatabase)

    test "set and get many":
        testSetAndGetMany(createDatabase)
