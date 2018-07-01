#!/usr/bin/env bash

set -euo pipefail

if (( $# != 4 )); then
  echo >2 "Usage $0 <user> <uid> <group> <gid>"
  exit 1
fi

user=$1
uid=$2
group=$3
gid=$4

if ! id -g ${gid} >/dev/null; then
  addgroup --gid=${gid} ${group} >&2
fi

if ! id -u ${uid} >/dev/null; then
  user=$1
  adduser --disabled-login --gecos "" --uid=${uid} --gid=${gid} --home=/home/${user} ${user} >&2
fi

# Ensure the user has passwordless sudo to make experimenting with image tweaks easier.
echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user}
