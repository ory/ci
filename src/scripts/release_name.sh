#!/bin/bash

set -Eeuo pipefail

if [[ -z "${CIRCLE_TAG-}" ]]; then
  echo "# This is not a git tag, reverting to the git hash"
  echo "export RELEASE_NAME=${CIRCLE_SHA1}"
  echo "export DOCKER_FULL_TAG=${CIRCLE_SHA1}"
  echo "export DOCKER_SHORT_TAG=${CIRCLE_SHA1}"
  echo "export GORELEASER_CURRENT_TAG=${CIRCLE_SHA1}"
  exit 0
fi

release_list=$(curl -s "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases")
release_name=$(jq -c -r '.[] | select(.tag_name == "'"${CIRCLE_TAG}"'") | .name' <(echo "${release_list}"))

if [[ ${release_name} == "${CIRCLE_TAG}"* ]]; then
  echo "export RELEASE_NAME=${release_name}"
  echo "export DOCKER_FULL_TAG=$(echo "${CIRCLE_TAG}" | tr '+' '_')"
  echo "export DOCKER_SHORT_TAG=$(echo "${CIRCLE_TAG}" | cut -d '+' -f1)"
  echo "export GORELEASER_CURRENT_TAG=$(echo "${CIRCLE_TAG}" | cut -d '+' -f1)"
else
  echo "Exected the release title to contain the git tag which was not the case!"
  printf "Release title:\t\t%s\n" "${release_name}"
  printf "Git tag:\t\t%s\n" "${CIRCLE_TAG}"
  printf "Release:\t\t%s\n" "$(jq -r '.[] | select(.tag_name == "'"${CIRCLE_TAG}"'") | .' <(echo "${release_list}"))"
  exit 1
fi
