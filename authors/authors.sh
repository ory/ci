#!/usr/bin/env bash

# This script creates an AUTHORS file similar to https://github.com/google/go-github/blob/master/AUTHORS
# listing the authors of the product in the current directory. Call it like this:
#
#   curl https://raw.githubusercontent.com/ory/ci/master/authors/authors.sh | bash

# CONFIGURATION

# name of the file to create
filename=AUTHORS

# entries to ignore
ignores=()

# IMPLEMENTATION

# parse and verify arguments
product=$1
if [ -z "$product" ]; then
  echo "Usage: $0 <product name>"
  exit 1
fi

# determine authors from Git history
authors=$(git log --pretty=format:"%an <%ae>" | sort | uniq)

# filter authors who don't want to be listed
for ignore in "${ignores[@]}"; do
  authors=$(echo "$authors" | grep -v "$ignore")
done

# write file
echo "# This is the official list of $product authors." >$filename
echo "#" >>$filename
echo "# If you don't want to be on this list, please contact Ory." >>$filename
echo "" >>$filename
echo "$authors" >>$filename
