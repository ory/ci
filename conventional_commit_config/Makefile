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
	echo installing Node dependencies ...
	npm ci
	touch node_modules  # update timestamp so that Make doesn't reinstall Prettier each time it runs

.SILENT:
.DEFAULT_GOAL := help
