#!/bin/bash

set -Eeuox pipefail

if [ -z ${CIRCLE_TAG+x} ]; then
  if [[ "$(git show -s --format=%B | head -n 1)" == "autogen"* ]]; then
    echo "Skipping task because previous commit was generated by it"
    circleci-agent step halt
    exit 0
  fi
fi

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)

make .bin/clidoc
.bin/clidoc .

(
  cd docs && make format
)

(git add -A; git commit -a -m "autogen(docs): generate cli docs" &&  /
  git push origin HEAD:"$CIRCLE_BRANCH") || true
