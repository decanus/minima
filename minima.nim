# Minima
#
# Copyright (c) 2020 Dean Eigenmann
# Licensed under MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

## An embeddable database written in Nim.
## 
## Opening a database
## ------------------
## 
## .. code-block::
##   let result = open("/tmp/minima")
##   if not result.isOk:
##     return
## 
##   let db = result.value
##
## Opening an encrypted database
## -----------------------------
## 
## .. code-block::
##   let result = open("/tmp/minima", "password".toAESKey)
##   if not result.isOk:
##     return
## 
##   let db = result.value
##
## Inserting data
## --------------
## 
## .. code-block::
##   let result = db.set(@[byte 1, 2, 3, 4], @[byte 1, 2, 3])
##   if not result.isOk
##     echo result.error
## 
## Reading data
## ------------
## .. code-block::
##   let result = db.get(@[byte 1, 2, 3, 4])
##   if not result.isOk
##     echo result.error
##     return
## 
##   echo result.value
## 
## Notes
## =====
## 
## **This software is still pre-alpha, and should not be considered reliable.** 
## Here are some caveats that should be taken into consideration when using Minima:
## 1. The maximum length of both keys and values are **2^32-1** this is because we internally use **uint32** to represent the length of both fields. 

import minima/database
export database