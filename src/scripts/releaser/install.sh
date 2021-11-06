#!/bin/bash

set -Eeuox pipefail

curl -Lo "goreleaser-pro_Linux_x86_64.tar.gz" "https://github.com/goreleaser/goreleaser-pro/releases/download/${2}-pro/goreleaser-pro_Linux_x86_64.tar.gz"
mkdir -p goreleaser-pro_Linux_x86_64
tar -xvf goreleaser-pro_Linux_x86_64.tar.gz -C goreleaser-pro_Linux_x86_64
mv goreleaser-pro_Linux_x86_64/goreleaser "$1/goreleaser-pro"
rm -rf goreleaser-pro_Linux_x86_64.* goreleaser_Linux_x86_64/
