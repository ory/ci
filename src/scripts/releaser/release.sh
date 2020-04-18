#!/bin/bash

set -Eeuox pipefail

export GORELEASER_CURRENT_TAG="${CIRCLE_TAG}"

if [[ ! -e package.json ]]; then
  echo '{"private": true, "version": "0.0.0"}' > package.json
  git add package.json
else
  echo "package.json exists and needs not be written"
fi

changelog=$(mktemp)
notes=$(mktemp)
preset=$(mktemp -d)

npm --no-git-tag-version version "$CIRCLE_TAG"
git clone git@github.com:ory/changelog.git "$preset"
(cd "$preset"; npm i)

git tag -l --format='%(contents)' "$CIRCLE_TAG" > "$notes"
conventional-changelog --config "$preset/index.js" -r 2 -o "$changelog"

printf "\n\n" >> "$notes"
cat "$changelog" >> "$notes"

git reset --hard HEAD
goreleaser release --release-notes <(cat "$notes")
