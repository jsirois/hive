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

PUSH_IMAGES="${PUSH_IMAGES:-}"
DOCKER_LOGIN=""

function maybe_login() {
  local -r creds="$1"
  
  if [[ "${DOCKER_LOGIN}" != "${creds}" ]]; then
    echo "${creds/:/ }" | while read docker_user docker_pass; do
      echo "${docker_pass}" | docker login -u "${docker_user}" --password-stdin
      DOCKER_LOGIN="${creds}"
    done  
  fi
}

function maybe_pull() {
  local -r tag="$1"
  local -r hash="$2"

  if [[ -n "${PUSH_IMAGES}" ]]; then
    docker pull ${tag}-${hash}
    docker tag ${tag}-${hash} ${tag}
  else
    return 1
  fi
}

function maybe_push() {
  local -r tag="$1"
  local -r hash="$2"

  if [[ -n "${PUSH_IMAGES}" ]]; then
    docker tag ${tag} ${tag}-${hash}
    maybe_login "${PUSH_IMAGES}"
    docker push ${tag}-${hash}
  else
    return 0
  fi
}

if [[ -z "$(base_id)" ]]; then
  maybe_pull ${IMAGE}:base ${base_hash} || (
    docker build \
      --tag ${IMAGE}:base \
      --label base_hash=${base_hash} \
        "${ROOT}/docker/base"
  
    maybe_push ${IMAGE}:base ${base_hash}
  )
fi

user_name="$(id -un)"
user_hash=$(hash_dir "${ROOT}/docker/user")
if [[ -z "$(docker images -q -f label=user_hash=${user_hash} ${IMAGE}:${user_name})" ]]; then
  maybe_pull ${IMAGE}:${user_name} ${user_hash} || (
    user_context="$(mktemp -d)"
    cp -rp "${ROOT}/docker/user"/* "${user_context}"
    cp -rp "${ROOT}/.nvmrc" "${user_context}/nvm/.nvmrc"
    cp -rp "${ROOT}/rust-toolchain" "${user_context}/rust/rust-toolchain"

    docker build \
      --build-arg BASE_ID=$(base_id) \
      --build-arg USER=${user_name} \
      --build-arg UID=$(id -u) \
      --build-arg GROUP=$(id -gn) \
      --build-arg GID=$(id -g) \
      --tag ${IMAGE}:${user_name} \
      --label user_hash=${user_hash} \
        "${user_context}"

    maybe_push ${IMAGE}:${user_name} ${user_hash}
  )
fi

exec docker run \
  --interactive \
  --tty \
  --rm \
  -p 8000:8000 \
  --volume $(pwd):/dev/hive \
  ${IMAGE}:${user_name} \
  "$*"
