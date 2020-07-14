SHELL := /bin/bash

docs:
	nim doc --project --git.url:https://github.com/decanus/minima --o:docs minima.nim
.PHONY: docs

test:
	nimble test
.PHONY: test 
