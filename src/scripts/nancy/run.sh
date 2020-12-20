#!/bin/bash

set -Eeuox pipefail

curl -L -o $GOPATH/bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.5/nancy-linux.amd64-v1.0.5 && chmod +x $GOPATH/bin/nancy

go list -m all | nancy -quiet # -exclude-vulnerability fc041c7e-0c64-4b74-991e-64196a704ace,2bfd5f1a-e9b5-4a04-b4e8-15091e145845,40365e0e-8b3c-4252-8124-dbbec0a45dfe
