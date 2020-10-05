#!/bin/bash

set -Eeuox pipefail

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
bash <(curl https://raw.githubusercontent.com/ory/cli/master/install.sh) -b $GOPATH/bin

git fetch origin
git checkout -b master origin/master

ory dev schema render-version $CIRCLE_PROJECT_REPONAME $CIRCLE_TAG

git commit -a -m "autogen: add $CIRCLE_TAG to version.schema.json"
git push origin master
