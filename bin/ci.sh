#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

# TODO(John Sirois): Conditionally generate the travis image and push or else pull it.

${ROOT}/bin/dev_env.sh bash -ic "brunch build app && cargo make --cwd server"
