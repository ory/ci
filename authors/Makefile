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

format: .bin/shfmt
	echo formatting source code ...
	.bin/shfmt --write .

test: .bin/shellcheck .bin/shfmt  # runs all automated tests
	echo running tests ...
	.bin/shellcheck authors.sh
	.bin/shfmt --diff .

.bin/shellcheck: Makefile
	echo installing Shellcheck ...
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz | tar xJ
	mkdir -p .bin
	mv shellcheck-stable/shellcheck .bin
	rm -rf shellcheck-stable
	touch .bin/shellcheck   # update the timestamp so that Make doesn't re-install Shellcheck each time it runs

.bin/shfmt: Makefile
	mkdir -p .bin
	curl -sSL https://github.com/mvdan/sh/releases/download/v3.10.0/shfmt_v3.10.0_$(OS)_$(ARCH) -o .bin/shfmt
	chmod +x .bin/shfmt

.SILENT:
