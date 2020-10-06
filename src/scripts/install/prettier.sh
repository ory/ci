#!/bin/bash

set -Eeuox pipefail

mkdir -p node_modules/ory-prettier-styles
tar -xf "$(npm pack ory-prettier-styles)" -C node_modules/ory-prettier-styles --strip-components=1
sudo npm i -g "prettier@$(jq -r '.devDependencies.prettier' package.json)"
rm ory-prettier-styles-*.tgz
