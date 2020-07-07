# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

import sequtils, stew/endians2

type 
    Log* = ref object of RootObj
        file: File

    UnencryptedLog* = ref object of Log

method log*(log: Log, key: seq[byte], value: seq[byte]) {.base.} =
    discard

method close*(log: Log) {.base.} =
    log.file.close()

method next*(log: Log): (seq[byte], seq[byte]) {.base.} =
    discard

iterator pairs*(log: Log): (seq[byte], seq[byte]) =
    while log.file.getFilePos() <= log.file.getFileSize() - 1:
        var (k, v) = log.next()
        yield (k, v)

proc readInt(file: File): int =
    var arr: array[4, byte]
    discard file.readBytes(arr, 0, 4)

    return int(uint32.fromBytes(arr))

proc init*(T: type UnencryptedLog, file: File): T =
    result = T(file: file)

method log*(log: UnencryptedLog, key: seq[byte], value: seq[byte]) =
    let write = concat(
        @(uint32(len(key)).toBytes),
        @(uint32(len(value)).toBytes),
        key,
        value
    )

    # @TODO CATCH EXCEPTIONS
    discard log.file.writeBytes(write, 0, len(write))
    log.file.flushFile()

method next*(log: UnencryptedLog): (seq[byte], seq[byte]) =
    var keyLen = readInt(log.file)
    var valLen = readInt(log.file)

    # @TODO CATCH EXCEPTIONS

    var key = newSeq[byte](keyLen)
    discard log.file.readBytes(key, 0, keyLen)

    var val = newSeq[byte](valLen)
    discard log.file.readBytes(val, 0, valLen)

    return (key, val)