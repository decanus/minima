# minima

![Test](https://github.com/decanus/minima/workflows/Test/badge.svg)

MinimaDB: An embeddable database written in Nim.

```nim
let db = open("/tmp/minima")

let key = [byte 1, 2, 3, 4]

# Insert
db.set(key, [byte 4, 3, 2, 1])

# Get
let val = db.get(key)
```
