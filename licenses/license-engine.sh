#!/bin/bash

# This script detects non-compliant licenses in the output of language-specific license checkers.

# These licenses are allowed (complete license string for legal certainty, in regex format)
ALLOWED_LICENSES=(
	'0BSD'
	'AFLv2.1'
	'(AFL-2.1 OR BSD-3-Clause)'
	'Apache-2.0'
	'Apache*'
	'BSD-2-Clause'
	'BSD-3-Clause'
	'CC0-1.0'
	'CC-BY-4.0'
	'(CC-BY-4.0 AND MIT)'
	'ISC'
	'MIT'
	'MIT*'
	'(MIT OR Apache-2.0)'
	'MPL-2.0'
	'Unlicense'
	'(WTFPL OR MIT)'
)

# These modules don't work with the current license checkers
# and have been manually verified to have a compatible license.
APPROVED_MODULES=(
	'github.com/ory/kratos-client-go'                   # Apache-2.0
	'github.com/ory/hydra-client-go'                    # Apache-2.0
	'github.com/gobuffalo/github_flavored_markdown'     # MIT
	'buffers@0.1.1'                                     # MIT: original source at http://github.com/substack/node-bufferlist is deleted, but a fork at https://github.com/pkrumins/node-bufferlist/blob/master/LICENSE contains the original license by the original author (James Halliday)
	'https://github.com/iconify/iconify/packages/react' # MIT, license is in root of monorepo at https://github.com/iconify/iconify/blob/main/license.txt
)

# These lines in the output should be ignored (regex format).
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
	input=$(echo "$input" | grep -vF "$ignored")
done

# remove allowed licenses
for allowed in "${ALLOWED_LICENSES[@]}"; do
	input=$(echo "$input" | grep -vF "\"${allowed}\"")
done

# remove pre-approved modules
for approved in "${APPROVED_MODULES[@]}"; do
	input=$(echo "$input" | grep -vF "\"${approved}\"")
	input=$(echo "$input" | grep -vF "\"Custom: ${approved}\"")
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
