# minima

[![Test](https://github.com/decanus/minima/workflows/Test/badge.svg)](https://github.com/decanus/minima/actions?query=workflow%3ATest)

MinimaDB: A persistent & embeddable KV store written in Nim.

```nim

import stew/results, minima

let result = open("/tmp/minima")
if not result.isOk:
    echo result.error()
    return

db = result.value

let key = @[byte 1, 2, 3, 4]

# Insert
db.set(key, @[byte 4, 3, 2, 1])

# Get
let val = db.get(key)
```

# Caveats

**This software is still pre-alpha, and should not be considered reliable.** Here are some caveats that should be taken into consideration when using Minima:
 - The maximum length of both keys and values are `2^32-1` this is because we internally use `uint32`s to represent the length of both fields. 
