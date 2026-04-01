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

: "${MERGED_GWAS_PREFIX:?Set MERGED_GWAS_PREFIX in config/project.env}"
: "${SPARSE_GRM_PREFIX:?Set SPARSE_GRM_PREFIX in config/project.env}"
: "${PHENO_FILE:?Set PHENO_FILE in config/project.env}"
: "${COVAR_FILE:?Set COVAR_FILE in config/project.env}"

GCTA_BIN="${GCTA_BIN:-gcta64}"
GWAS_OUT_PREFIX="${GWAS_OUT_PREFIX:-GWAS_LSADT}"

"${GCTA_BIN}" \
  --bfile "${MERGED_GWAS_PREFIX}" \
  --grm-sparse "${SPARSE_GRM_PREFIX}" \
  --fastGWA-mlm \
  --pheno "${PHENO_FILE}" \
  --covar "${COVAR_FILE}" \
  --out "${GWAS_OUT_PREFIX}"
