import unittest

import ../minima/[log, database], stew/[results, byteutils], os, sequtils

type
    InitProc = proc (): Log

proc openFile(): File =
    if not os.existsDir("/tmp"):
        os.createDir("/tmp")

    var path = "/tmp/minima.db"
    var mode = fmReadWrite
    if fileExists(path):
        mode = fmReadWriteExisting

    return open(path, mode)

proc createEncryptedLog(): Log =
    var f = openFile()
    EncryptedLog.init(f, "password".toAESKey)

proc createStandardLog(): Log =
    var f = openFile()
    StandardLog.init(f)

suite "Encrypted Log Test":
    teardown:
        removeFile("/tmp/minima.db")
        
    test "can read and write":
        var log = createEncryptedLog()

        let key = @[byte 1, 2, 3, 4]
        let value = @[byte 1, 2, 3, 4, 5]

        log.log(key, value)
        log.close()

        log = createEncryptedLog()

        for (k, v) in log.pairs():
            check:
                k == key
                v == value

suite "Log Test":
    teardown:
        removeFile("/tmp/minima.db")

    test "can read and write":
        var log = createStandardLog()

        let key = @[byte 1, 2, 3, 4]
        let value = @[byte 1, 2, 3, 4, 5]

        log.log(key, value)
        log.close()

        log = createStandardLog()

        for (k, v) in log.pairs():
            check:
                k == key
                v == value