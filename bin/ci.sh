#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

cargo make --cwd ${ROOT}/server ci-flow
cargo make --cwd ${ROOT}/server bundle
