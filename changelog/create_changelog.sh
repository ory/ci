#!/usr/bin/env bash
set -e

# This script updates CHANGELOG.md.
# It does commit the changes since that doesn't make sense during development.
# This needs to happen separately on CI.

echo
echo "VERIFY THAT THE CHANGELOG IS NOT ALREADY GENERATED ..."
if [[ "$(git show -s --format=%B | head -n 1)" == "autogen"* ]]; then
	exit 0
fi

echo
echo "FETCH GIT METADATA ..."
git fetch origin +refs/tags/*:refs/tags/*
git fetch --unshallow

echo
echo "INSTALL TOOLS ..."
npm ci
rm -rf changelog
git clone https://github.com/ory/changelog.git
(cd changelog && npm ci)

echo
echo "GENERATE THE CHANGELOG ..."
npm exec -- conventional-changelog --config "changelog/index.js" -r 0 -u -o CHANGELOG.md
npm exec -- doctoc CHANGELOG.md
sed -i "s/\*\*Table of Contents.*/**Table of Contents**/" CHANGELOG.md
sed -i "s/\*This Change Log was.*/This Change Log was automatically generated/" CHANGELOG.md
t=$(mktemp)
printf "# Changelog\n\n" | cat - CHANGELOG.md >"$t" && mv "$t" CHANGELOG.md

echo
echo "FORMAT THE CHANGELOG ..."
# NOTE: need to format twice because of https://github.com/prettier/prettier/issues/13213
npm exec -- prettier --write CHANGELOG.md
npm exec -- prettier --write CHANGELOG.md
npm exec -- prettier --check CHANGELOG.md

echo
echo "CLEANUP ..."
rm -rf changelog/
