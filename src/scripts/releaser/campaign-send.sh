#!/bin/bash

set -Eeuox pipefail

if [ -z "${CIRCLE_SHA1}" ]
then
  export CIRCLE_SHA1=$(git rev-parse HEAD | cut -c 1-16)
fi
if [ -z "${CIRCLE_TAG}" ]
then
  export CIRCLE_TAG=$(git tag --points-at HEAD)
fi

bash <(curl https://raw.githubusercontent.com/ory/release/master/install.sh) -b $GOPATH/bin

release campaign send "${MAILCHIMP_LIST_ID}"
