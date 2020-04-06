#!/bin/bash

set -Eeuox pipefail

if [[ "$(git show -s --format=%B | head -n 1)" == "autogen"* ]]; then
  echo "Skipping task because previous commit was generated by it"
  circleci-agent step halt
  exit 0
fi

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/swagger.sh)
bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)

swagger generate spec -m -o "${SWAG_SPEC_LOCATION}" -x "${SWAG_SPEC_IGNORE}"
swagutil sanitize "${SWAG_SPEC_LOCATION}"
swagger flatten --with-flatten=remove-unused -o "${SWAG_SPEC_LOCATION}" "${SWAG_SPEC_LOCATION}"
swagger validate "${SWAG_SPEC_LOCATION}"

(cd docs; npm i)

npx widdershins@3.6.7 -u docs/.widdershins/templates -e docs/.widdershins/config.json $SWAG_SPEC_LOCATION -o ./docs/docs/reference/api.md

node ./docs/scripts/fix-api.js ./docs/docs/reference/api.md
node ./docs/scripts/config.js docs/config.js

if [ -n "${CIRCLE_TAG+x}" ]; then
  doc_tag=$(echo "${CIRCLE_TAG}" | cut -d '+' -f1 | cut -d '.' -f-2)
  node ./docs/scripts/docker-tag.js docs/config.js "$CIRCLE_TAG"
  node ./docs/scripts/rerelease.js "$doc_tag"
  rm -rf ./docs/versioned_docs/version-"$doc_tag"
  rm -rf ./docs/versioned_sidebars/version-"$doc_tag"-sidebars.json
  (cd docs; npm run docusaurus docs:version "$doc_tag")
fi

(cd docs; \
  npm run format && \
  npm run build
)

if [ -n "${CIRCLE_TAG+x}" ]; then
  echo "Pushing to master becase this is a git tag."
  git checkout -b "$(date +%s)"
  git add -A
  (git commit -a -m "autogen(docs): generate and format documentation" && git push origin HEAD:master) || true
else
  echo "Pushing to master becase this is a git tag."
  git add -A
  (git commit -a -m "autogen(docs): generate and format documentation" && git push origin HEAD:"$CIRCLE_BRANCH") || true
fi

website_path="../web/${CIRCLE_PROJECT_REPONAME}/docs"
git clone git@github.com:ory/web.git ../web
rm -rf "$website_path"
cp -R ./docs/build/* "$website_path"
(cd ../web; \
  git add -A; \
  (git commit -a -m "autogen(docs): generate and bump docs for $CIRCLE_PROJECT_REPONAME" && git push origin HEAD:master) || true)

