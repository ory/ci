#!/bin/bash

set -Eeuox pipefail

export GORELEASER_CURRENT_TAG="${CIRCLE_TAG}"

if [[ ! -e package.json ]]; then
  echo '{"private": true, "version": "0.0.0"}' > package.json
  git add package.json
else
  echo "package.json exists and needs not be written"
fi

notes="$(mktemp).md"
preset=$(mktemp -d)

npm --no-git-tag-version version "$CIRCLE_TAG"
git clone git@github.com:ory/changelog.git "$preset"
(cd "$preset"; npm i)

npx conventional-changelog-cli@v2.1.1 --config "$preset/index.js" -r 2 -o "$notes"

# Replace all h1 headings from the changelog.
cat $notes
sed '/^# /d' "$notes" | tee "$notes"

# Format it
cat $notes
npx prettier -w "$notes"

cat $notes
git reset --hard HEAD
cat $notes

goreleaser release --release-header <(cat "$notes") --rm-dist --timeout 60m --parallelism 1
