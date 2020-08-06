#!/bin/bash

set -Eeuox pipefail

hub=${DOCKER_HUB_NAME:-oryd}

BINARY_NAME=$CIRCLE_PROJECT_REPONAME
if [[ $CIRCLE_PROJECT_REPONAME = "cli" ]] ;then
  BINARY_NAME="ory"
fi

curl -sSfL \
  "https://raw.githubusercontent.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/master/install.sh" \
  | sh -s "${CIRCLE_TAG}"

"./bin/${BINARY_NAME}" help
"./bin/${BINARY_NAME}" version | grep -q "${CIRCLE_TAG}" || exit 1

docker run --rm \
  "${hub}/${CIRCLE_PROJECT_REPONAME}:${CIRCLE_TAG}" help
docker run --rm \
  "${hub}/${CIRCLE_PROJECT_REPONAME}:${CIRCLE_TAG}" version | grep -q "${CIRCLE_TAG}" || exit 1
