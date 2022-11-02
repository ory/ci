format:  # formats all code bases
	(cd changelog && make --no-print-dir format)
	(cd conventional_commit_config && make --no-print-dir format)
	(cd licenses && make --no-print-dir format)

help:
	@cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '.SILENT:' | grep -v '^node_modules:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

licenses:
	@echo No license checks necessary in this repo.

.DEFAULT_GOAL := help
