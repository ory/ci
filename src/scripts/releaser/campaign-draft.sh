#!/bin/bash

set -Eeuox pipefail

if [[ ! -e package.json ]]; then
    echo '{"private": true, "version": "0.0.0"}' > package.json
fi

if [ -z "${CIRCLE_SHA1}" ]
then
  export CIRCLE_SHA1=$(git rev-parse HEAD | cut -c 1-16)
fi
if [ -z "${CIRCLE_TAG}" ]
then
  export CIRCLE_TAG=$(git tag --points-at HEAD)
fi

changelogFile=$(mktemp)
noteFile=$(mktemp)
presetDir=$(mktemp -d)

npm --no-git-tag-version version "$CIRCLE_TAG"
git clone git@github.com:ory/changelog.git "$presetDir"
(cd "$presetDir"; npm i)

npx conventional-changelog-cli@v1.1.0 --config "$presetDir/email.js" -r 2 -o "$changelogFile"

notes=$(git tag -l --format='%(contents)' "$CIRCLE_TAG")
if [ "${notes}" == "$(git log --format=%B -n 1 HEAD)" ]; then
  echo "Git tag does not include any release noteFile."
  echo "${notes}" > "${noteFile}"
fi

if grep -iqF "no significant changes" < "$changelogFile" && [ -z "$(cat "$noteFile")" ]; then
  echo "Changelog would be empty, skipping campaign send!"
  exit 0
fi

release campaign draft --segment "${MAILCHIMP_SEGMENT_ID}" "${MAILCHIMP_LIST_ID}" "$noteFile" "$changelogFile"

echo "## Release Notes ##"
cat "$noteFile"

echo "## Changelog ##"
cat "$changelogFile"

release campaign send --dry "${MAILCHIMP_LIST_ID}"
