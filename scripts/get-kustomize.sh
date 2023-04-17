#!/bin/bash

set -euo pipefail

VERSION="4.2.0"

ROOT=$(git rev-parse --show-toplevel)
DEST="$ROOT/kustomize/bin"

mkdir -p "$ROOT/build/tmp"
cd "$ROOT/build/tmp"

echo Fetching Kustomize version "$VERSION"
for OS in linux darwin; do
    for ARCH in amd64 arm64; do
        curl -s -O -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${VERSION}/kustomize_v${VERSION}_${OS}_${ARCH}.tar.gz"

        test -e kustomize_v${VERSION}_${OS}_${ARCH}.tar.gz || {
            echo failed to download kustomize
            exit 1
        }
    done
done

echo done.
