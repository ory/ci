OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(shell uname -m)
ifeq ($(ARCH),x86_64)
	ARCH=amd64
else ifeq ($(ARCH),arm64)
	ARCH=arm64
else ifeq ($(ARCH),aarch64)
	ARCH=arm64
else ifeq ($(ARCH),i386)
	ARCH=386
else ifeq ($(ARCH),i686)
	ARCH=386
endif

format: .bin/shfmt node_modules  # formats the source code
	echo formatting source code ...
	npm exec -- prettier --write .
	.bin/shfmt --write .

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '^node_modules' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

ps: format test  # performs all automated assistance functions during development ("pitstop")

test: .bin/shellcheck .bin/shfmt  # runs all automated tests
	echo running tests ...
	find . -type f | grep -v node_modules | grep -v '^\.\/\.bin\/' | grep -v '\.json$$' | grep -v '\.yml$$' | xargs grep -l '^\#!\/' | xargs .bin/shellcheck
	.bin/shfmt --diff .

.bin/shellcheck: Makefile
	echo installing Shellcheck ...
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.$(OS).$(ARCH).tar.xz | tar xJ
	mkdir -p .bin
	mv shellcheck-stable/shellcheck .bin
	rm -rf shellcheck-stable
	touch .bin/shellcheck   # update the timestamp so that Make doesn't re-install Shellcheck each time it runs

.bin/shfmt: Makefile
	mkdir -p .bin
	curl -sSL https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_$(OS)_$(ARCH) -o .bin/shfmt
	chmod +x .bin/shfmt

node_modules: package-lock.json
	echo installing Prettier ...
	npm ci
	touch node_modules

.SILENT:
.DEFAULT_GOAL := help
