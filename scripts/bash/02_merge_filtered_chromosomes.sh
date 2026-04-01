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

: "${BASE_DIR:?Set BASE_DIR in config/project.env}"

PLINK_BIN="${PLINK_BIN:-plink1.9}"
FILTERED_DIR="${FILTERED_DIR:-${BASE_DIR}/filtered_data}"
MERGED_DIR="${MERGED_DIR:-${FILTERED_DIR}/merged_final}"

mkdir -p "${MERGED_DIR}"

merge_list="${MERGED_DIR}/merge_list.txt"
> "${merge_list}"

for chr in $(seq 2 22); do
  echo "${FILTERED_DIR}/filtered_chr${chr}/step5_hwe" >> "${merge_list}"
done

"${PLINK_BIN}" \
  --bfile "${FILTERED_DIR}/filtered_chr1/step5_hwe" \
  --merge-list "${merge_list}" \
  --make-bed \
  --out "${MERGED_DIR}/merged_final"
