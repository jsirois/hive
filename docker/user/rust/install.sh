#!/usr/bin/env bash

set -euo pipefail

export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

which rustup || curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none

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
)

for tool in ${CARGO_TOOLS[@]}; do
  which "${tool}" || cargo install "${tool}"
done

cat << EOF >> "${HOME}/.bashrc"

export CARGO_HOME="${CARGO_HOME}"
export PATH="\${PATH}:\${CARGO_HOME}/bin"
EOF

