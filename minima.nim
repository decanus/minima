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
## Notes
## =====
## 
## **This software is still pre-alpha, and should not be considered reliable.** 
## Here are some caveats that should be taken into consideration when using Minima:
## 1. The maximum length of both keys and values are **2^32-1** this is because we internally use **uint32**s to represent the length of both fields. 

import minima/database
export database