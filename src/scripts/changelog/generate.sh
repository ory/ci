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

npm --no-git-tag-version version "$CIRCLE_TAG"
git clone git@github.com:ory/changelog.git "$preset"
(cd "$preset"; npm i)

npx conventional-changelog-cli --config "$preset/index.js" -r 0 -u -o CHANGELOG.md

npx doctoc CHANGELOG.md

sed -i "s/\*\*Table of Contents.*/**Table of Contents**/" CHANGELOG.md
sed -i "s/\*This Change Log was.*/This Change Log was automatically generated/" CHANGELOG.md

if [ -f package.json ]; then
  bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)
  npm run format
fi

git add CHANGELOG.md

t=$(mktemp)
printf "# Changelog\n\n" | cat - CHANGELOG.md > "$t" && mv "$t" CHANGELOG.md

if [ -z ${isRelease+x} ]; then
  git add -A
  (git commit -m "$COMMIT_MESSAGE" -- CHANGELOG.md && git pull -ff && git push origin HEAD:$CIRCLE_BRANCH) || true
else
  git add -A
  git fetch origin
  git checkout -b "changelog-$(date +"%m-%d-%Y")" origin/master
  git pull -ff
  (git commit -m "$COMMIT_MESSAGE" -- CHANGELOG.md && git pull -ff && git push origin HEAD:master) || true
fi
