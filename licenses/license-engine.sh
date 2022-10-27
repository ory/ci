#!/bin/bash

# This script detects non-compliant licenses in the output of language-specific license checkers.

ALLOWED_LICENSES=(
	'AFLv2.1'
	'Apache-2.0'
	'Apache\*?'
	'BSD-[23]-Clause'
	'CC0-1.0'
	'ISC'
	'MIT'
	'MPL-2.0'
	'Unlicense'
)

# these modules have been manually verified to have the correct license
APPROVED_MODULES=(
	'github.com/ory/kratos-client-go'
	'github.com/ory/hydra-client-go'
	'github.com/gobuffalo/github_flavored_markdown'
	'http://github.com/substack/node-bufferlist'
)

echo_green() {
	printf "\e[1;92m%s\e[0m\n" "$@"
}

echo_red() {
	printf "\e[0;91m%s\e[0m\n" "$@"
}

echo_help() {
	echo "USAGE: $0 <OPTIONS>"
	echo
	echo "OPTIONS:"
	echo "--stack go|node"
	echo "--ignore <module name>"
	echo
	echo "EXAMPLES:"
	echo "$0 --stack go"
	echo "$0 --stack node"
	echo "$0 --stack go --ignore github.com/ory/hydra-client-go"
}

# parse CLI args
while [ -n "$1" ]; do
	if [ "$1" = "--stack" ]; then
		shift
		STACK=$1
		shift
	elif [ "$1" = "--ignore" ]; then
		shift
		APPROVED_MODULES+=("$1")
		shift
	else
		echo_red "ERROR: unknown command-line parameter: '$1'"
		echo_help
		exit 1
	fi
done

# verify CLI args
if [ -z "$STACK" ]; then
	echo_red "ERROR: no stack provided"
	echo_help
	exit 1
elif [ "$STACK" = "go" ]; then
	SKIP=2
elif [ "$STACK" = "node" ]; then
	SKIP=1
else
	echo_red ERROR: Unknown stack: "$STACK"
	echo Please provide either "go" or "node"
	exit 1
fi

# capture STDIN
unknown=$(cat - | tail -n +$SKIP)

# filter allowed licenses
for allowed in "${ALLOWED_LICENSES[@]}"; do
	unknown=$(echo "$unknown" | grep -v "$allowed")
done

# filter approved modules
for approved in "${APPROVED_MODULES[@]}"; do
	unknown=$(echo "$unknown" | grep -v "$approved")
done

# print outcome
if [ -z "$unknown" ]; then
	echo_green "Licenses are okay."
else
	echo_red "Unknown licenses found!"
	echo
	echo "$unknown"
	exit 1
fi
