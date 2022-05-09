#!/bin/bash

set -euo pipefail

VERSION="0.8.0"

ROOT=$(git rev-parse --show-toplevel)
DEST="$ROOT/controller-gen/bin"

test -d "$ROOT/build/tmp" && rm -rf "$ROOT/build/tmp"
mkdir -p "$ROOT/build/tmp"
cd "$ROOT/build/tmp"

# Fetch and unpack v0.8.0
echo "Downloading and extracting controller-tools version $VERSION"
curl -sL "https://github.com/kubernetes-sigs/controller-tools/archive/v${VERSION}.tar.gz" | tar xfz -

cd "controller-tools-$VERSION"

mkdir -p "$ROOT/bin"
echo "Building controller-gen"
GOOS=darwin GOARCH=amd64 go build ./cmd/controller-gen
mv controller-gen "$DEST/controller-gen.darwin"
GOOS=linux GOARCH=amd64 go build ./cmd/controller-gen
mv controller-gen "$DEST/controller-gen.linux"

echo "Binaries built:"
file "$DEST"/*
