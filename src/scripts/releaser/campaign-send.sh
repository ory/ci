#!/bin/bash

set -Eeuox pipefail

bash <(curl https://raw.githubusercontent.com/ory/cli/master/install.sh) -b $GOPATH/bin

ory dev release notify send "${MAILCHIMP_LIST_ID}"
