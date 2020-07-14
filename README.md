# minima

[![Test](https://github.com/decanus/minima/workflows/Test/badge.svg)](https://github.com/decanus/minima/actions?query=workflow%3ATest)

MinimaDB: A persistent & embeddable KV store written in Nim.

## Usage

Opening a Minima database is super simple, you simply pass a directory to the `open` function indicating where you want your database saved:

```nim
import minima

let result = open("/tmp/minima")
if not result.isOk:
    echo result.error()
    return
```

A database can also be encrypted by passing a password:

```nim
import minima

let result = open("/tmp/minima", "password".toAESKey)
if not result.isOk:
    echo result.error()
    return
```

> Note: You can not mix between the encrypted and unencrypted database opening functions. This will not work.

Once a database has been opened, working with Minima is just as simple:

```nim
let db = result.value

let key = @[byte 1, 2, 3, 4]

# Insert
db.set(key, @[byte 4, 3, 2, 1])

# Get
let val = db.get(key)
```

## Caveats

**This software is still pre-alpha, and should not be considered reliable.** Here are some caveats that should be taken into consideration when using Minima:
 - The maximum length of both keys and values are `2^32-1` this is because we internally use `uint32`s to represent the length of both fields. 
 - The way the log currently saves Key Value pairs is not very efficient, this is because the buffer is flushed to disk on every write. This will be changed in the future.
