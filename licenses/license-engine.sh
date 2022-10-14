#!/bin/sh

# This script detects non-compliant licenses in the output of language-specific license checkers.

print_green() {
	tput setaf 2
	tput bold
	echo "$@"
	tput sgr0
}

print_red() {
	tput setaf 1
	tput bold
	echo "$@"
	tput sgr0
}

unknown=$(
	cat - |
		tail -n +2 |
		grep -v '\bAFLv2.1\b' |
		grep -v '\bApache-2.0\b' |
		grep -Ev '\bApache\*?\b' |
		grep -v '\bBSD-[23]-Clause\b' |
		grep -v '\bCC0-1.0\b' |
		grep -v '\bISC\b' |
		grep -v '\bMIT\b' |
		grep -v '\bMPL-2.0\b' |
		grep -v '\bUnlicense\b' |
		grep -v '\bgithub.com/ory/kratos-client-go\b' |
		grep -v '\bgithub.com/gobuffalo/github_flavored_markdown\b' |
		grep -v '\bhttp://github.com/substack/node-bufferlist\b'
)
if [ -z "$unknown" ]; then
	print_green "Licenses are okay."
else
	print_red "Unknown licenses found!"
	echo
	echo "$unknown"
	exit 1
fi
