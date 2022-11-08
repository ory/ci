#!/usr/bin/env bash

# This script creates an AUTHORS file similar to https://github.com/google/go-github/blob/master/AUTHORS
# listing the authors of the product in the current directory. Call it like this:
#
#   env PRODUCT=<product name> curl https://raw.githubusercontent.com/ory/ci/master/authors/authors.sh | bash

# CONFIGURATION

# name of the file to create
filename=AUTHORS

# entries to ignore
ignores=(ory-bot dependabot)

# IMPLEMENTATION

# parse and verify arguments
if [ -z "$PRODUCT" ]; then
  echo "Usage: env PRODUCT=<product name>" "$0"
  exit 1
fi

# determine authors from Git history
authors=$(git log --pretty=format:"%an <%ae>" | sort | uniq)

# filter authors who don't want to be listed
for ignore in "${ignores[@]}"; do
  authors=$(echo "$authors" | grep -v "$ignore")
done

# gather statistics
count=$(echo "$authors" | wc -l)

# write file
echo "# This is the official list of $PRODUCT authors." >$filename
echo "# If you don't want to be on this list, please contact Ory." >>$filename
echo "" >>$filename
echo "$authors" >>$filename

echo "Identified $count contributors."
