#!/usr/bin/env bash

set -euo pipefail

NVM_DIR="${HOME}/.nvm"
if [[ ! -d "${NVM_DIR}" ]]; then
  curl -sSfL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash -
fi
export NVM_DIR

source "${NVM_DIR}/nvm.sh" || true

node_version="$(cat "$(dirname "$0")"/.nvmrc)"
nvm use "${node_version}" || nvm install "${node_version}"

NPM_TOOLS=(
  brunch
  elm
)

for tool in ${NPM_TOOLS[@]}; do
  which "${tool}" || NODE_VERSION="${node_version}" "${NVM_DIR}/nvm-exec" npm install -g "${tool}"
done
