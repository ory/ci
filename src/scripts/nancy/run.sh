#!/bin/bash

set -Eeuox pipefail

curl -L -o $GOPATH/bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.15/nancy-v1.0.15-linux-amd64 && chmod +x $GOPATH/bin/nancy

go list -m all | nancy sleuth -q
