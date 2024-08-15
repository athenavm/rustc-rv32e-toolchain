#!/usr/bin/env bash

set -euo pipefail

cd rust
patch -N -p1 < ../patches/rust.patch
cp ../patches/config.toml ./
