import unittest

import ../minima/database, stew/results, os

suite "Database Test Suite":

    var db: Database

    setup:
        var result = database.open("/tmp")
        check:
            result.isOk 

        db = result.value

    teardown:
        removeFile("/tmp/minima.db")

    test "can set and get key":
        let key = @[byte 1, 2, 3, 4]
        let value = @[byte 4, 3, 2, 1]
        
        var setResult = db.set(key, value)
        check:
            setResult.isOk

        var getResult = db.get(key)

        check:
            getResult.isOk
            getResult.value == value

    test "has returns expected value":
        let key = @[byte 1, 2, 3, 4, 5]
        check:
            not db.has(key)

        discard db.set(key, key)
        check:
            db.has(key)

    test "recover works":
        let vals = [@[byte 1, 2, 3, 4], @[byte 1, 2, 3, 4, 5], @[byte 1, 2, 3, 4, 5, 6]]

        for val in vals:
            discard db.set(val, val)

        db.close()

        var result2 = database.open("/tmp")
        check:
            result2.isOk

        var newDB = result.value

        for val in vals:
            var getResult = newDB.get(val)
            check:
                getResult.isOk
                getResult.value == val
