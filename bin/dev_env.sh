#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

IMAGE="jsirois/hive"

function hash_dir() {
  local -r dir="$1"

  cat $(find "${dir}" -mindepth 1 -type f | sort) | git hash-object -t blob --stdin
}

base_image="${IMAGE}:base"
base_context="${ROOT}/docker/base"
base_hash=$(hash_dir "${base_context}")

function base_id() {
  docker images -q -f label=base_hash=${base_hash} ${base_image}
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

function get_base_image() {
  if [[ -z "$(base_id)" ]]; then
    maybe_pull ${base_image} ${base_hash} || (
      docker build \
        --tag ${base_image} \
        --label base_hash=${base_hash} \
          "${base_context}"
  
      maybe_push ${base_image} ${base_hash}
    )
  fi
}

function get_user_image() {
  local -r user_name="$(id -un)"
  local -r user_image="${IMAGE}:${user_name}"
  local -r user_hash=$(hash_dir "${ROOT}/docker/user")

  if [[ -z "$(docker images -q -f label=user_hash=${user_hash} ${user_image})" ]]; then
    # Save stdout to fd3 and then redirect it to stderr.
    exec 3>&1 1>&2

    maybe_pull ${user_image} ${user_hash} || (
      get_base_image

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
        --tag ${user_image} \
        --label user_hash=${user_hash} \
          "${user_context}"

      maybe_push ${user_image} ${user_hash}
    )

    # Restore stdout and close fd3.
    exec 1>&3 3>&-
  fi

  echo ${user_image}
}

exec docker run \
  --interactive \
  --tty \
  --rm \
  -p 8000:8000 \
  --volume $(pwd):/dev/hive \
    $(get_user_image) \
      "$*"
