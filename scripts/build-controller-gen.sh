#!/bin/bash

set -euo pipefail

VERSIONS=(
    "0.3.0"
    "0.4.1"
)

ROOT=$(git rev-parse --show-toplevel)
DEST="$ROOT/controller-gen/bin"

test -d "$ROOT/build/tmp" && rm -rf "$ROOT/build/tmp"
mkdir -p "$ROOT/build/tmp"
cd "$ROOT/build/tmp"

# Fetch and unpack versions
for v in "${VERSIONS[@]}"
do
    echo "Downloading and extracting controller-tools version $v"
    curl -sL "https://github.com/kubernetes-sigs/controller-tools/archive/v${v}.tar.gz" | tar xfz -

    cd "controller-tools-$v"

    mkdir -p "$ROOT/bin"
    echo "Building controller-gen version $v"
    GOOS=darwin GOARCH=amd64 go build ./cmd/controller-gen
    mv controller-gen "$DEST/controller-gen-${v}.darwin-amd64"
    GOOS=linux GOARCH=amd64 go build ./cmd/controller-gen
    mv controller-gen "$DEST/controller-gen-${v}.linux"
    GOOS=darwin GOARCH=arm64 go build ./cmd/controller-gen
    mv controller-gen "$DEST/controller-gen-${v}.darwin-arm64"
done

echo "Binaries built:"
file "$DEST"/*
