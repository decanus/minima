# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

import sequtils, stew/[byteutils, endians2], nimAES

type 
    Log* = ref object of RootObj
        file: File

    StandardLog* = ref object of Log
    EncryptedLog* = ref object of Log
        aes: AESContext

method close*(log: Log) {.base.} =
    log.file.close()

method log*(log: Log, key: seq[byte], value: seq[byte]) {.base.} =
    discard

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

proc pack(key, value: seq[byte]): seq[byte] =
    concat(
        @(uint32(len(key)).toBytes),
        @(uint32(len(value)).toBytes),
        key,
        value
    )

proc init*(T: type StandardLog, file: File): T =
    result = T(file: file)

method log*(log: StandardLog, key: seq[byte], value: seq[byte]) =
    let write = pack(key, value)
    # @TODO CATCH EXCEPTIONS
    discard log.file.writeBytes(write, 0, len(write))
    log.file.flushFile()

method next*(log: StandardLog): (seq[byte], seq[byte]) =
    let keyLen = readInt(log.file)
    let valLen = readInt(log.file)

    # @TODO CATCH EXCEPTIONS

    var key = newSeq[byte](keyLen)
    discard log.file.readBytes(key, 0, keyLen)

    var val = newSeq[byte](valLen)
    discard log.file.readBytes(val, 0, valLen)

    return (key, val)

method log*(log: EncryptedLog, key: seq[byte], value: seq[byte]) =
    let data = log.aes.encryptECB(pack(key, value).toHex).toBytes()

    discard log.file.writeBytes(@(uint32(len(data)).toBytes), 0, 4)
    discard log.file.writeBytes(data, 0, len(data))
    log.file.flushFile()

method next*(log: EncryptedLog): (seq[byte], seq[byte]) =
    let dataLen = readInt(log.file)

    var data = newSeq[byte](dataLen)
    discard log.file.readBytes(data, 0, dataLen)

    let _ = string.fromBytes(data).hexToSeqByte()

    # @TODO, WHAT WE NEED TO DO IS FROM THE RETURN ABOVE
    # UNPACK THE pack() RESULT

    return (@[], @[])

