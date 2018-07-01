#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

IMAGE="jsirois/hive"

function hash_dir() {
  local -r dir="$1"

  cat $(find "${dir}" -mindepth 1 -type f | sort) | git hash-object -t blob --stdin
}

base_hash=$(hash_dir "${ROOT}/docker/base")

function base_id() {
  docker images -q -f label=base_hash=${base_hash} ${IMAGE}:base
}

if [[ -z "$(base_id)" ]]; then
  docker build \
    --tag ${IMAGE}:base \
    --label base_hash=${base_hash} \
    "${ROOT}/docker/base"
fi

user_hash=$(hash_dir "${ROOT}/docker/user")
if [[ -z "$(docker images -q -f label=user_hash=${user_hash} ${IMAGE}:user)" ]]; then
  user_context="$(mktemp -d)"
  cp -rp "${ROOT}/docker/user"/* "${user_context}"
  cp -rp "${ROOT}/.nvmrc" "${user_context}/nvm/.nvmrc"
  cp -rp "${ROOT}/rust-toolchain" "${user_context}/rust/rust-toolchain"

  docker build \
    --build-arg BASE_ID=$(base_id) \
    --build-arg USER=$(id -un) \
    --build-arg UID=$(id -u) \
    --build-arg GROUP=$(id -gn) \
    --build-arg GID=$(id -g) \
    --tag ${IMAGE}:user \
    --label user_hash=${user_hash} \
    "${user_context}"
fi

exec docker run \
  --interactive \
  --tty \
  --rm \
  -p 8000:8000 \
  --volume $(pwd):/dev/hive \
  ${IMAGE}:user \
  "$*"
