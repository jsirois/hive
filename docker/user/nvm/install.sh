#!/usr/bin/env bash

set -euo pipefail

curl -sSfL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash -

export NVM_DIR="${HOME}/.nvm"
source "${NVM_DIR}/nvm.sh"

node_version="$(cat "$(dirname "$0")"/.nvmrc)"
nvm install "${node_version}"

npm install -g brunch elm
