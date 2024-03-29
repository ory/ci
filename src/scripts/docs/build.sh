#!/bin/bash

set -Eeuox pipefail

if [ -z ${CIRCLE_TAG+x} ]; then
  if [[ "$(git show -s --format=%B | head -n 1)" == "autogen"* ]]; then
    echo "Skipping task because previous commit was generated by it"
    circleci-agent step halt
    exit 0
  fi
fi

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/swagger.sh)
bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
bash <(curl https://raw.githubusercontent.com/ory/meta/master/install.sh) -b $GOPATH/bin ory

# we want word splitting here to pass the args
# shellcheck disable=SC2046
# shellcheck disable=SC2086
make sdk

(cd docs; npm i; npm run gen)

export TERSER_PARALLEL=false

(
  cd docs
  npm run build && make format
)

if [ -n "${CIRCLE_TAG+x}" ]; then
  echo "Pushing to master because this is a git tag."
  branch="$(date +%s)"
  git checkout -b "$branch"
  git add -A
  git commit --allow-empty -a -m "autogen(docs): generate and format documentation"
  git pull origin master --rebase
  git push origin HEAD:master
else
  echo "Pushing to master because this is a git tag."
  git add -A
  git commit --allow-empty -a -m "autogen(docs): generate and format documentation"
  git pull origin $CIRCLE_BRANCH --rebase
  git push origin HEAD:"$CIRCLE_BRANCH"
fi

website_path="../web/generated/docs/${CIRCLE_PROJECT_REPONAME}"
git clone git@github.com:ory/web.git ../web
rm -rf "$website_path/*"
cp -R ./docs/build/* "$website_path"
(cd ../web; \
  git add -A; \
  git commit --allow-empty -a -m "autogen(docs): generate and bump docs for $CIRCLE_PROJECT_REPONAME"; \
  git push origin HEAD:master)

