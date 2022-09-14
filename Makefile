format: node_modules   # formats all code bases
	(cd changelog && make --no-print-dir format)
	(cd conventional_commit_config && make --no-print-dir format)

help:
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '.SILENT:' | grep -v '^node_modules:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t


.SILENT:
.DEFAULT_GOAL := help
