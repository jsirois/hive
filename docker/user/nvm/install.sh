#!/usr/bin/env bash

set -euo pipefail

curl -sSL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash -
export NVM_DIR="${HOME}/.nvm"

source "${NVM_DIR}/nvm.sh"
nvm install "$(cat $(dirname $0)/.nvmrc)"

npm install -g brunch elm

