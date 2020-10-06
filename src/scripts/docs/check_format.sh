#!/bin/bash

set -Eeuox pipefail

(cd docs
bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)
npm run format:check)
