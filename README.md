# minima

![Test](https://github.com/decanus/minima/workflows/Test/badge.svg)

MinimaDB: An embeddable database written in Nim.

```nim
let result = open("/tmp/minima")
if not result.isOk:
    return

db = result.value

let key = [byte 1, 2, 3, 4]

# Insert
db.set(key, [byte 4, 3, 2, 1])

# Get
let val = db.get(key)
```
