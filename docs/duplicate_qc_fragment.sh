BASE=/genetik1/.../Genetic_Data
KEEP=${BASE}/keep_samples_ipnr.txt

for CHR in {1..22}; do

CHRDIR=${BASE}/Chr${CHR}
OUTDIR=${BASE}/filtered_data/filtered_chr${CHR}
mkdir -p ${OUTDIR}

INFOFILE=${CHRDIR}/infofile_chr${CHR}.txt
SNPLIST=${OUTDIR}/chr${CHR}_info08.snplist

# STEP 0 — keep samples
plink1.9 \
--bfile ${CHRDIR}/bestguess_chr${CHR} \
--keep ${KEEP} \
--make-bed \
--out ${OUTDIR}/step0_keep

# STEP 1 — INFO ≥ 0.8
awk 'NR>1 && $7 >= 0.8 {print $2}' ${INFOFILE} > ${SNPLIST}

plink1.9 \
--bfile ${OUTDIR}/step0_keep \
--extract ${SNPLIST} \
--make-bed \
--out ${OUTDIR}/step1_info

# STEP 2 — SNP type
plink1.9 \
--bfile ${OUTDIR}/step1_info \
--snps-only just-acgt \
--make-bed \
--out ${OUTDIR}/step2_acgt

# STEP 3 — MAF
plink1.9 \
--bfile ${OUTDIR}/step2_acgt \
--maf 0.01 \
--make-bed \
--out ${OUTDIR}/step3_maf

# STEP 4 — GENO
plink1.9 \
--bfile ${OUTDIR}/step3_maf \
--geno 0.02 \
--make-bed \
--out ${OUTDIR}/step4_geno

# STEP 5 — HWE
plink1.9 \
--bfile ${OUTDIR}/step4_geno \
--hwe 1e-6 \
--make-bed \
--out ${OUTDIR}/step5_hwe

done