#!/usr/bin/env bash

set -euo pipefail

curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none

export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

rust_toolchain="$(cat "$(dirname "$0")"/rust-toolchain)"

RUST_COMPONENTS=(
  rustfmt-preview
  llvm-tools
)

rustup toolchain install "${rust_toolchain}"
rustup component add --toolchain "${rust_toolchain}" ${RUST_COMPONENTS[@]}
rustup override set "${rust_toolchain}"

CARGO_TOOLS=(
  cargo-make
  cargo-binutils
)

cargo install ${CARGO_TOOLS[@]}

cat << EOF >> "${HOME}/.bashrc"

export CARGO_HOME="${CARGO_HOME}"
export PATH="\${PATH}:\${CARGO_HOME}/bin"
EOF

