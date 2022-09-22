#!/bin/bash

set -Eeuox pipefail

if [[ ! -e package.json ]]; then
  echo '{"private": true, "version": "0.0.0"}' > package.json
  git add package.json
else
  echo "package.json exists and needs not be written"
fi

preset=$(mktemp -d)

if [ -z ${CIRCLE_TAG+x} ]; then
  CIRCLE_TAG=$(git describe --abbrev=0 --tags)
else
  isRelease=1
fi

git clone git@github.com:ory/changelog.git "$preset"
(cd "$preset"; npm i)

npx conventional-changelog-cli@2.1.1 --config "$preset/index.js" -r 0 -u -o CHANGELOG.md

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)

# If docs/docs exists, copy the changelog there.
# Reintroduce once https://github.com/facebook/docusaurus/issues/3018 is resolved
#if [ -d "docs/docs" ]; then
#  cat <<EOT >> docs/docs/CHANGELOG.md
#---
#id: changelog
#title: Changelog
#custom_edit_url: null
#---
#
#EOT
#  cat CHANGELOG.md >> docs/docs/CHANGELOG.md
#  git add docs/docs/CHANGELOG.md
#  (cd docs; make format)
#  rm docs/docs/CHANGELOG.md
#fi

# Adding a table of contents and other things really only makes sense
# for the CHANGELOG in the root repository.
npx doctoc CHANGELOG.md

sed -i "s/\*\*Table of Contents.*/**Table of Contents**/" CHANGELOG.md
sed -i "s/\*This Change Log was.*/This Change Log was automatically generated/" CHANGELOG.md

if [ -f Makefile ]; then
  make format
fi

git add CHANGELOG.md

t=$(mktemp)
printf "# Changelog\n\n" | cat - CHANGELOG.md > "$t" && mv "$t" CHANGELOG.md

if [ -z ${isRelease+x} ]; then
  (git commit -m "$COMMIT_MESSAGE" && git pull -ff && git push origin HEAD:$CIRCLE_BRANCH) || true
else
  git fetch origin
  git stash
  git checkout -b "changelog-$(date +"%m-%d-%Y")" origin/master
  git pull -ff
  git stash pop
  (git commit -m "$COMMIT_MESSAGE" && git pull -ff && git push origin HEAD:master) || true
fi
