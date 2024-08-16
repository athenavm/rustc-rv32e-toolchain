#!/usr/bin/env bash

set -euo pipefail

source config.sh

# Fail fast if these tools aren't properly installed and in the path
need_cmd riscv32-unknown-elf-clang
need_cmd riscv32-unknown-elf-clang++

# Rust requires a custom target file to exist for our custom target as part of the bootstrap build,
# but it doesn't actually look at the contents.
touch /tmp/riscv32em-athena-zkvm-elf.json
export RUST_TARGET_PATH="/tmp"

# Explicitly set CFLAGS without the problematic flags
export CFLAGS_riscv32em_athena_zkvm_elf="-ffunction-sections -fdata-sections -fPIC -target riscv32-unknown-elf"

# Set Rust flags
export CARGO_TARGET_RISCV32EM_ATHENA_ZKVM_ELF_RUSTFLAGS="-Cpasses=loweratomic -Clink-arg=-march=rv32em -Clink-arg=-mabi=ilp32e"
# export COMPILER_RT_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf"
# export CC_riscv32em_athena_zkvm_elf="clang"
# export CXX_riscv32em_athena_zkvm_elf="clang++"

# Prevent the build system from adding --target flag
export RUSTC_TARGET_ARG=""

# Will create component archives (dists) ./rust/build/dist
cd rust
./x build --stage 2
