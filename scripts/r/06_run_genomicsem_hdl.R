#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages(c("data.table", "GenomicSEM", "HDL"))

args <- commandArgs(trailingOnly = TRUE)
reference_rdata <- args[1] %||% "data/reference/UKB_imputed_hapmap2_SVD_eigen99_extraction/UKB_imputed_hapmap2_res_1e-08.RData"
ad_gwas_file <- args[2] %||% "results/GWAS_LSADT_ALZ.fastGWA"
dementia_gwas_file <- args[3] %||% "results/GWAS_LSADT_DEMENTIA.fastGWA"
ad_output <- args[4] %||% "results/AD.CLEAN.sumstats"
dementia_output <- args[5] %||% "results/DEM.CLEAN.sumstats"
ld_path <- args[6] %||% "data/reference/UKB_imputed_hapmap2_SVD_eigen99_extraction"
hdl_output <- args[7] %||% "results/hdl_genetic_correlation.rds"

load(reference_rdata)
ref_panel <- data.table::as.data.table(res.list$hm3_SNP)
ref_panel[, pos_key := paste(CHR, POS, sep = ":")]

map_snps_to_ref <- function(gwas_file, output_name, reference_panel) {
  gwas <- data.table::fread(gwas_file)
  gwas[, pos_key := paste(CHR, POS, sep = ":")]

  gwas_mapped <- merge(
    gwas,
    reference_panel[, .(pos_key, RSID)],
    by = "pos_key",
    all.x = TRUE
  )

  gwas_mapped[, SNP_clean := ifelse(!is.na(RSID), RSID, sub(":.*", "", SNP))]

  sumstats <- gwas_mapped[, .(
    SNP = SNP_clean,
    A1 = A1,
    A2 = A2,
    Z = BETA / SE,
    N = N
  )]
  sumstats <- unique(sumstats, by = "SNP")

  ensure_parent_dir(output_name)
  data.table::fwrite(sumstats, output_name, sep = "	", quote = FALSE)
  nrow(sumstats)
}

ad_n <- map_snps_to_ref(ad_gwas_file, ad_output, ref_panel)
dementia_n <- map_snps_to_ref(dementia_gwas_file, dementia_output, ref_panel)

hdl_result <- HDL::hdl(
  traits = c(ad_output, dementia_output),
  sample.prev = c(0.251, NA),
  population.prev = c(0.12, NA),
  LD.path = ld_path,
  method = "jackknife"
)

ensure_parent_dir(hdl_output)
saveRDS(
  list(
    mapped_snps = c(alzheimers = ad_n, dementia = dementia_n),
    hdl_result = hdl_result
  ),
  hdl_output
)

print(hdl_result)
