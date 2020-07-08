# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

import sequtils, stew/[byteutils, endians2], nimcrypto, random

type 
    Log* = ref object of RootObj
        file*: File

    StandardLog* = ref object of Log
    EncryptedLog* = ref object of Log
        key: array[aes256.sizeKey, byte]
        iv: array[aes256.sizeBlock, byte]

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

proc init*(T: type EncryptedLog, file: File, key: array[aes256.sizeKey, byte]): T =
    var aliceIv = "0123456789ABCDEF"
    var iv: array[aes256.sizeBlock, byte]
    
    # @TODO IV NEEDS TO BE REGENERATED EVERY WRITE
    
    copyMem(addr iv[0], addr aliceIv[0], len(aliceIv))
    result = T(file: file, key: key, iv: iv)

proc randomIV(): array[aes256.sizeBlock, byte] =
    randomize()

    for i in 0 ..< result.len:
        result[i] = byte(rand(256))

method log*(log: EncryptedLog, key: seq[byte], value: seq[byte]) =
    let packet = pack(key, value)

    let iv = randomIV()

    var encrypt: CTR[aes256]
    encrypt.init(log.key, iv)
    
    var encrypted = newSeq[byte](len(packet))
    encrypt.encrypt(packet, encrypted)

    let write = concat(@(uint32(len(encrypted)).toBytes), @iv, encrypted)

    discard log.file.writeBytes(write, 0, len(write))
    log.file.flushFile()

method next*(log: EncryptedLog): (seq[byte], seq[byte]) =
    let encryptedLen = readInt(log.file)

    var iv: array[aes256.sizeBlock, byte]
    discard log.file.readBytes(iv, 0, aes256.sizeBlock)

    var encrypted = newSeq[byte](encryptedLen)
    discard log.file.readBytes(encrypted, 0, encryptedLen)

    var data = newSeq[byte](encryptedLen)

    var decrypt: CTR[aes256]
    decrypt.init(log.key, iv)
    decrypt.decrypt(encrypted, data)

    let keyLen = uint32.fromBytes(@(data.toOpenArray(0, 3)))
    let valLen = uint32.fromBytes(@(data.toOpenArray(4, 7)))

    let keyEnd = 8 + int(keyLen - 1)
    let key = @(data.toOpenArray(8, keyEnd))

    let valStart = keyEnd + 1

    let value = @(data.toOpenArray(valStart, valStart + int(valLen - 1)))

    return (
        key,
        value
    )

