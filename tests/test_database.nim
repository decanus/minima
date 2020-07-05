import unittest

import ../minima/database, stew/results, os

suite "Database Test Suite":
    test "can set and get key":
        removeFile("/tmp/minima.db")

        var result = database.open("/tmp")
        check:
            result.isOk

        var db = result.value
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
        removeFile("/tmp/minima.db")

        var result = database.open("/tmp")
        check:
            result.isOk

        var db = result.value

        let key = @[byte 1, 2, 3, 4, 5]
        check:
            not db.has(key)

        discard db.set(key, key)
        check:
            db.has(key)

    test "recover works":
        removeFile("/tmp/minima.db")

        var result = database.open("/tmp")
        check:
            result.isOk

        var db = result.value

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
