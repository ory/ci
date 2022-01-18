#!/bin/bash

set -Eeuox pipefail

bash <(curl https://raw.githubusercontent.com/ory/meta/master/install.sh) -b $GOPATH/bin ory

ory dev release notify send "${MAILCHIMP_LIST_ID}"
