# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

import stew/[byteutils, endians2], sequtils

type
    Log* = object
        file: File

proc log*(log: Log, key: seq[byte], value: seq[byte]) =
    let write = concat(
        @(uint32(len(key)).toBytes),
        @(uint32(len(value)).toBytes),
        key,
        value
    )

    let length = len(write)
    # @TODO CATCH EXCEPTIONS
    let written = log.file.writeBytes(write, 0, length)
    if written != length:
        # @todo error
        discard
    
    log.file.flushFile()