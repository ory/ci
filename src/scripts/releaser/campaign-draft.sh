#!/bin/bash

set -Eeuox pipefail

bash <(curl https://raw.githubusercontent.com/ory/meta/master/install.sh) -b $GOPATH/bin ory

ory dev release notify draft --segment "${MAILCHIMP_SEGMENT_ID}" "${MAILCHIMP_LIST_ID}"

ory dev release notify send --dry "${MAILCHIMP_LIST_ID}"
