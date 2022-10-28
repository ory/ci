#!/bin/bash

# This script detects non-compliant licenses in the output of language-specific license checkers.

# These licenses are allowed (regex format)
ALLOWED_LICENSES=(
	'AFLv2.1'
	'(AFL-2.1 OR BSD-3-Clause)'
	'Apache-2.0'
	'Apache\*'
	'BSD-[23]-Clause'
	'CC0-1.0'
	'ISC'
	'MIT'
	'MIT\*'
	'MPL-2.0'
	'Unlicense'
)

# These modules don't work with the current license checkers
# and have been manually verified to have a compatible license.
APPROVED_MODULES=(
	'github.com/ory/kratos-client-go'               # Apache-2.0
	'github.com/ory/hydra-client-go'                # Apache-2.0
	'github.com/gobuffalo/github_flavored_markdown' # MIT
	'buffers@0.1.1'                                 # MIT: original source at http://github.com/substack/node-bufferlist is deleted, but a fork at https://github.com/pkrumins/node-bufferlist/blob/master/LICENSE contains the original license by the original author (James Halliday)
)

# These lines in the output should be ignore (regex format).
IGNORE_LINES=(
	'"module name","licenses"' # header of license output for Node.js
)

echo_green() {
	printf "\e[1;92m%s\e[0m\n" "$@"
}

echo_red() {
	printf "\e[0;91m%s\e[0m\n" "$@"
}

# capture STDIN
input=$(cat -)

# remove ignored lines
for ignored in "${IGNORE_LINES[@]}"; do
	input=$(echo "$input" | grep -v "$ignored")
done

# remove allowed licenses
for allowed in "${ALLOWED_LICENSES[@]}"; do
	input=$(echo "$input" | grep -v "\"${allowed}\"")
done

# remove pre-approved modules
for approved in "${APPROVED_MODULES[@]}"; do
	input=$(echo "$input" | grep -v "\"${approved}\"")
done

# print outcome
if [ -z "$input" ]; then
	echo_green "Licenses are okay."
else
	echo_red "Unknown licenses found!"
	echo
	echo "$input"
	exit 1
fi
