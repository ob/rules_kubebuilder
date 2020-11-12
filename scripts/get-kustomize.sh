#!/bin/bash

set -euo pipefail

VERSION="3.8.4"

ROOT=$(git rev-parse --show-toplevel)
DEST="$ROOT/km/bin"

mkdir -p "$ROOT/build/tmp"
cd "$ROOT/build/tmp"

echo Fetching Kustomize version "$VERSION"
for OS in linux darwin; do
    curl -s -O -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${VERSION}/kustomize_v${VERSION}_${OS}_amd64.tar.gz"

    test -e kustomize_v${VERSION}_${OS}_amd64.tar.gz || {
        echo failed to download kustomize
        exit 1
    }

    tar xfx kustomize_v${VERSION}_${OS}_amd64.tar.gz

    mv kustomize "$DEST/kustomize.$OS"
done

echo done.
file "$DEST"/*

