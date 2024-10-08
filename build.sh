#!/usr/bin/env bash

set -euo pipefail

source config.sh

# Fail fast if these tools aren't properly installed and in the path
need_cmd riscv64-unknown-elf-gcc
need_cmd riscv64-unknown-elf-g++

# Rust requires a custom target file to exist for our custom target as part of the bootstrap build,
# but it doesn't actually look at the contents.
touch /tmp/riscv32em-athena-zkvm-elf.json

# Will create component archives (dists) ./rust/build/dist
cd rust
RUST_TARGET_PATH="/tmp" \
CARGO_TARGET_RISCV32EM_ATHENA_ZKVM_ELF_RUSTFLAGS="-Cpasses=loweratomic" \
CFLAGS_riscv32em_athena_zkvm_elf="-ffunction-sections -fdata-sections -fPIC -march=rv32em -mabi=ilp32e" \
./x build --stage 2
