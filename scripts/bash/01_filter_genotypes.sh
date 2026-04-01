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
: "${KEEP_SAMPLES_FILE:?Set KEEP_SAMPLES_FILE in config/project.env}"

PLINK_BIN="${PLINK_BIN:-plink1.9}"
FILTERED_DIR="${FILTERED_DIR:-${BASE_DIR}/filtered_data}"
INFO_THRESHOLD="${INFO_THRESHOLD:-0.8}"
MAF_THRESHOLD="${MAF_THRESHOLD:-0.01}"
GENO_THRESHOLD="${GENO_THRESHOLD:-0.02}"
HWE_THRESHOLD="${HWE_THRESHOLD:-1e-6}"

for chr in $(seq 1 22); do
  chr_dir="${BASE_DIR}/Chr${chr}"
  out_dir="${FILTERED_DIR}/filtered_chr${chr}"
  info_file="${chr_dir}/infofile_chr${chr}.txt"
  snp_list="${out_dir}/chr${chr}_info${INFO_THRESHOLD}.snplist"

  mkdir -p "${out_dir}"

  echo "Filtering chromosome ${chr}..."

  "${PLINK_BIN}" \
    --bfile "${chr_dir}/bestguess_chr${chr}" \
    --keep "${KEEP_SAMPLES_FILE}" \
    --make-bed \
    --out "${out_dir}/step0_keep"

  awk -v threshold="${INFO_THRESHOLD}" 'NR > 1 && $7 >= threshold { print $2 }' \
    "${info_file}" > "${snp_list}"

  "${PLINK_BIN}" \
    --bfile "${out_dir}/step0_keep" \
    --extract "${snp_list}" \
    --make-bed \
    --out "${out_dir}/step1_info"

  "${PLINK_BIN}" \
    --bfile "${out_dir}/step1_info" \
    --snps-only just-acgt \
    --make-bed \
    --out "${out_dir}/step2_acgt"

  "${PLINK_BIN}" \
    --bfile "${out_dir}/step2_acgt" \
    --maf "${MAF_THRESHOLD}" \
    --make-bed \
    --out "${out_dir}/step3_maf"

  "${PLINK_BIN}" \
    --bfile "${out_dir}/step3_maf" \
    --geno "${GENO_THRESHOLD}" \
    --make-bed \
    --out "${out_dir}/step4_geno"

  "${PLINK_BIN}" \
    --bfile "${out_dir}/step4_geno" \
    --hwe "${HWE_THRESHOLD}" \
    --make-bed \
    --out "${out_dir}/step5_hwe"
done
