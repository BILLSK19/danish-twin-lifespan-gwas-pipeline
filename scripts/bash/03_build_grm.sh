#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/config/project.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Missing config file: ${CONFIG_FILE}"
  echo "Copy config/project.env.example to config/project.env and update the paths."
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

: "${LD_PRUNED_PREFIX:?Set LD_PRUNED_PREFIX in config/project.env}"

GCTA_BIN="${GCTA_BIN:-gcta64}"
GRM_PREFIX="${GRM_PREFIX:-GRM_full}"

"${GCTA_BIN}" \
  --bfile "${LD_PRUNED_PREFIX}" \
  --make-grm \
  --out "${GRM_PREFIX}"
