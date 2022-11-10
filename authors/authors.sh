#!/usr/bin/env bash

# This script creates an AUTHORS file similar to https://github.com/google/go-github/blob/master/AUTHORS
# listing the authors of the product in the current directory. Call it like this:
#
# 	curl https://raw.githubusercontent.com/ory/ci/master/authors/authors.sh | env PRODUCT=<product name> bash

##############################
# CONFIGURATION

# name of the file to create
filename=AUTHORS

# entries to ignore
ignores=(ory-bot dependabot circleci@ory.am kevin.goslar@originate.com)

##############################
# IMPLEMENTATION

# verify arguments
if [ -z "$PRODUCT" ]; then
	echo "Usage: env PRODUCT=<product name>" "$0"
	exit 1
fi

# verify complete Git history
if [ "$(git rev-parse --is-shallow-repository)" = "false" ]; then
	echo "I need the full Git history in this repo"
	exit 1
fi

# determine all authors from the Git history
authors=$(git log --pretty=format:"%an <%ae>" | sort | uniq)

# filter entries to ignore
for ignore in "${ignores[@]}"; do
	authors=$(echo "$authors" | grep -v "$ignore")
done

# write file
{
	echo "# This is the official list of $PRODUCT authors."
	echo "# If you don't want to be on this list, please contact Ory."
	echo ""
	echo "$authors"
} >$filename

# print success message
count=$(echo "$authors" | wc -l)
echo "Identified $count contributors."
