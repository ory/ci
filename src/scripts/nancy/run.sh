#!/bin/bash

set -Eeuox pipefail

curl -L -o $GOPATH/bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.5/nancy-linux.amd64-v1.0.5 && chmod +x $GOPATH/bin/nancy

go list -m all | nancy sleuth -q
