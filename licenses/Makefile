format: .bin/shfmt node_modules  # formats the source code
	echo formatting source code ...
	.bin/shfmt --write .
	npm exec -- prettier --write .

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '^node_modules' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

.bin/shfmt: Makefile
	echo installing Shellfmt ...
	mkdir -p .bin
	curl -sSL https://github.com/mvdan/sh/releases/download/v3.5.1/shfmt_v3.5.1_linux_amd64 -o .bin/shfmt
	chmod +x .bin/shfmt

node_modules: package.json package-lock.json
	echo installing Prettier ...
	npm ci
	touch node_modules


.SILENT:
.DEFAULT_GOAL := help
