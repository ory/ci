#!/bin/bash

set -Eeuox pipefail

bash <(curl https://raw.githubusercontent.com/ory/cli/master/install.sh) -b $GOPATH/bin

ory dev release notify draft --segment "${MAILCHIMP_SEGMENT_ID}" "${MAILCHIMP_LIST_ID}"

ory dev release notify send --dry "${MAILCHIMP_LIST_ID}"
