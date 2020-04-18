#!/bin/bash

set -Eeuox pipefail

if [[ ! -e package.json ]]; then
    echo '{"private": true, "version": "0.0.0"}' > package.json
fi

GO111MODULES=off go get -u github.com/ory/release
GO111MODULES=off go install github.com/ory/release

changelog=$(mktemp)
notes=$(mktemp)
preset=$(mktemp -d)

npm --no-git-tag-version version "$CIRCLE_TAG"
git clone git@github.com:ory/changelog.git "$preset"
(cd "$preset"; npm i)

npx conventional-changelog-cli@v1.1.0 --config "$preset/email.js" -r 2 -o "$changelog"
git tag -l --format='%(contents)' "$CIRCLE_TAG" > "$notes"

release notify --segment "${MAILCHIMP_SEGMENT_ID}" "${MAILCHIMP_LIST_ID}" "$notes" "$changelog"
