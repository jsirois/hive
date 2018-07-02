#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

${ROOT}/bin/dev_env.sh cargo make --cwd server ci-flow
${ROOT}/bin/dev_env.sh cargo make --cwd server bundle
