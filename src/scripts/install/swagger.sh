#!/bin/bash

set -Eeuox pipefail

version=v0.23.0

path=$GOPATH/bin

download_url=$(curl -s https://api.github.com/repos/go-swagger/go-swagger/releases | \
  jq -r '.[] | select(.tag_name=="'"${version}"'") | .assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url')
sudo curl -o "$path/swagger" -L'#' "$download_url"
sudo chmod +x "$path/swagger"

bash <(curl https://raw.githubusercontent.com/ory/meta/master/install.sh) -b $GOPATH/bin ory
