#!/bin/bash

set -Eeuox pipefail

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
bash <(curl https://raw.githubusercontent.com/ory/cli/master/install.sh) -b $GOPATH/bin

ory dev schema render-version $CIRCLE_PROJECT_REPONAME $CIRCLE_TAG $SCHEMA_PATH

branch="$(date +%s)"
git fetch origin
git stash || true
git checkout -b "$branch"
git stash pop || true
git add -A
git commit -a -m "autogen: add $CIRCLE_TAG to version.schema.json" || true
git pull origin master --rebase || true
git push origin HEAD:master || true
