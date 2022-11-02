build: node_modules  # compiles the file that runs on CI
	echo compiling Typescript ...
	npm exec -- tsc --project tsconfig.build.json
	echo bundling code ...
	npm exec -- ncc build lib/action.js
	echo generating json-schema ...
	npm exec -- typescript-json-schema tsconfig.json FileFormat --noExtraProps -o dist/config.schema.json

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

format: node_modules  # formats the source code
	npm exec -- prettier --write .

test: node_modules  # runs all automated tests
	echo running ESLint ...
	npm exec -- eslint .
	echo running unit tests ...
	npm exec -- mocha

node_modules: package-lock.json
	npm ci
	touch node_modules

.SILENT:
.DEFAULT_GOAL := help
