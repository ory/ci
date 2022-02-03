#!/bin/bash

set -Eeuox pipefail

export GORELEASER_CURRENT_TAG="${CIRCLE_TAG}"

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)

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
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' '/^# /d' "$notes"
else
  sed -i '/^# /d' "$notes"
fi
cat $notes

# Format it
npx prettier -w "$notes"

git reset --hard HEAD

cat $notes

goreleaser release --release-header <(cat "$notes") --rm-dist --timeout 60m --parallelism 1 --debug

git add -A
git stash || true
git checkout master || true
git stash pop || true
git commit -a -m "autogen: update release artifacts" || true
git pull origin master --rebase || true
git push origin HEAD:master || true
