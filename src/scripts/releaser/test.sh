#!/bin/bash

set -Eeuox pipefail

curl -sSfL \
  "https://raw.githubusercontent.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/master/install.sh" \
  | sh -s "${CIRCLE_TAG}"

"./bin/${CIRCLE_PROJECT_REPONAME}" help
"./bin/${CIRCLE_PROJECT_REPONAME}" version | grep -q "${CIRCLE_TAG}" || exit 1

docker run --rm \
  "${DOCKER_HUB_NAME}/${CIRCLE_PROJECT_REPONAME}:${CIRCLE_TAG}" help
docker run --rm \
  "${DOCKER_HUB_NAME}/${CIRCLE_PROJECT_REPONAME}:${CIRCLE_TAG}" version | grep -q "${CIRCLE_TAG}" || exit 1
