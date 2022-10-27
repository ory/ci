#!/bin/bash

# This script detects non-compliant licenses in the output of language-specific license checkers.

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
}

# parse CLI args
IGNORES=()
while [ -n "$1" ]; do
  if [ "$1" = "--stack" ]; then
    shift
    STACK=$1
    shift
  elif [ "$1" = "--ignore" ]; then
    shift
    IGNORES+=("$1")
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

# filter known good licenses from
unknown=$(
  cat - |            # create a pipe containing STDIN
    tail -n +$SKIP | # skip the first N lines of the output because it contains headers or other output
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

# filter modules to ignore
for ignore in "${IGNORES[@]}"; do
  echo "FILTERING $ignore from $unknown"
  unknown=$(echo "$unknown" | grep -v "$ignore")
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
