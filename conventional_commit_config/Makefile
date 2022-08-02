build: node_modules  # compiles the file that runs on CI
	node_modules/.bin/tsc --project tsconfig.build.json
	node_modules/.bin/ncc build lib/action.js
	node_modules/.bin/typescript-json-schema tsconfig.json FileFormat --noExtraProps -o dist/config.schema.json

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

node_modules: package.json package-lock.json  # installs third-party dependencies for Node.js
	npm ci

format: node_modules  # formats the source code
	node_modules/.bin/prettier --write .

test: node_modules  # runs all automated tests
	node_modules/.bin/eslint .
	node_modules/.bin/mocha

.SILENT:
.DEFAULT_GOAL := help
