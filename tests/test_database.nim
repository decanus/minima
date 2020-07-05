import unittest

import ../minima/database, stew/results

suite "Database Test Suite":
    test "can set and get key":
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
        var result = database.open("/tmp")
        check:
            result.isOk

        var db = result.value

        let key = @[byte 1, 2, 3, 4]
        check:
            not db.has(key)

        discard db.set(key, key)
        check:
            db.has(key)
