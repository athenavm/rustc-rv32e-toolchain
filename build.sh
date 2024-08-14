#!/usr/bin/env bash

set -euo pipefail

source config.sh

# Fail fast if these tools aren't properly installed and in the path
need_cmd riscv32-unknown-elf-clang
need_cmd riscv32-unknown-elf-clang++

# Rust requires a custom target file to exist for our custom target as part of the bootstrap build,
# but it doesn't actually look at the contents.
cat > /tmp/riscv32em-athena-zkvm-elf.json << EOF
{
  "arch": "riscv32",
  "cpu": "generic-rv32",
  "crt-objects-fallback": "false",
  "data-layout": "e-m:e-p:32:32-i64:64-n32-S32",
  "eh-frame-header": false,
  "emit-debug-gdb-scripts": false,
  "features": "+e,+m",
  "linker": "rust-lld",
  "linker-flavor": "gnu-lld",
  "llvm-abiname": "ilp32e",
  "llvm-target": "riscv32",
  "max-atomic-width": 32,
  "os": "zkvm",
  "panic-strategy": "abort",
  "relocation-model": "static",
  "singlethread": true,
  "target-pointer-width": "32",
  "vendor": "athena",
  "options": {
    "c-flags": "-march=rv32e -mabi=ilp32e",
    "pre-link-args": {
      "gcc": [
        "-march=rv32e",
        "-mabi=ilp32e"
      ]
    }
  }
}
EOF

# Set environment variables to override compiler flags
export CC_riscv32em_athena_zkvm_elf="clang"
export CXX_riscv32em_athena_zkvm_elf="clang++"
#export AR_riscv32em_athena_zkvm_elf="ar"

# Explicitly set CFLAGS without the problematic flags
export CFLAGS_riscv32em_athena_zkvm_elf="-ffunction-sections -fdata-sections -fPIC -target riscv32-unknown-elf"
export CXXFLAGS_riscv32em_athena_zkvm_elf="$CFLAGS_riscv32em_athena_zkvm_elf"

# Set Rust flags
export CARGO_TARGET_RISCV32EM_ATHENA_ZKVM_ELF_RUSTFLAGS="-Cpasses=loweratomic -Clink-arg=-march=rv32em -Clink-arg=-mabi=ilp32e"

# Override the default target for compiler-rt
export COMPILER_RT_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf"

# Force the use of our custom target spec
export RUST_TARGET_PATH="/tmp"

# Prevent the build system from adding --target flag
export RUSTC_TARGET_ARG=""

# Will create component archives (dists) ./rust/build/dist
cd rust
./x build --stage 2
