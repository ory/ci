#!/usr/bin/env bash

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

echo
echo "INSTALL TOOLS ..."
npm i --no-save conventional-changelog-cli@v2.1.1 doctoc@v1.4.0 prettier@2.7.1
git clone https://github.com/ory/changelog.git
(cd changelog && npm ci)

echo
echo "GENERATE THE CHANGELOG ..."
node_modules/.bin/conventional-changelog --config "changelog/index.js" -r 0 -u -o CHANGELOG.md
node_modules/.bin/doctoc CHANGELOG.md
sed -i "s/\*\*Table of Contents.*/**Table of Contents**/" CHANGELOG.md
sed -i "s/\*This Change Log was.*/This Change Log was automatically generated/" CHANGELOG.md
t=$(mktemp)
printf "# Changelog\n\n" | cat - CHANGELOG.md >"$t" && mv "$t" CHANGELOG.md

echo
echo "FORMAT ..."
# NOTE: need to format twice because of https://github.com/prettier/prettier/issues/13213
node_modules/.bin/prettier --write CHANGELOG.md
node_modules/.bin/prettier --write CHANGELOG.md
node_modules/.bin/prettier --check CHANGELOG.md

echo
echo "CLEANUP ..."
rm -rf changelog/
