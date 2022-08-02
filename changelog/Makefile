format: .bin/shfmt  # formats the source code
	echo formatting source code ...
	.bin/shfmt --write create_changelog.sh

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

test: .bin/shellcheck .bin/shfmt  # runs all linters
	echo running tests ...
	 .bin/shellcheck create_changelog.sh
	echo Verifying formatting ...
	.bin/shfmt --list create_changelog.sh

.bin/shellcheck: Makefile
	echo installing Shellcheck ...
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz | tar xJ
	mkdir -p .bin
	mv shellcheck-stable/shellcheck .bin
	rm -rf shellcheck-stable
	touch .bin/shellcheck   # update the timestamp so that Make doesn't re-install the file over and over again

.bin/shfmt: Makefile
	echo installing Shellfmt ...
	mkdir -p .bin
	curl -sSL https://github.com/mvdan/sh/releases/download/v3.5.1/shfmt_v3.5.1_linux_amd64 -o .bin/shfmt
	chmod +x .bin/shfmt

.SILENT:
.DEFAULT_GOAL := help
