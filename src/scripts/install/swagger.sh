#!/bin/bash

set -Eeuox pipefail

version=v0.23.0

download_url=$(curl -s https://api.github.com/repos/go-swagger/go-swagger/releases | \
  jq -r '.[] | select(.tag_name=="'"${version}"'") | .assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url')
sudo curl -o $PATH/swagger -L'#' "$download_url"
sudo chmod +x $PATH/swagger

go get github.com/ory/sdk/swagutil@master
