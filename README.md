# Danish Twin Lifespan and GWAS Pipeline

![R](https://img.shields.io/badge/R-analysis-276DC3?logo=r&logoColor=white) ![PLINK](https://img.shields.io/badge/PLINK-1.9-0A7F8C) ![GCTA](https://img.shields.io/badge/GCTA-fastGWA-4C956C) ![License](https://img.shields.io/badge/license-MIT-black)

This repository contains scripts for Danish twin lifespan analyses, a GWAS workflow, and GenomicSEM/HDL-based genetic correlation analysis.

## Overview

The project has three components:

1. Lifespan analysis in R:
   - lifespan scatter plot by birth year
   - twin-pair survival summary table
   - conditional lifespan plot by cotwin lifespan, sex, and zygosity
2. Genetics workflow with PLINK and GCTA:
   - chromosome-level genotype filtering
   - merging filtered chromosomes
   - GRM construction
   - `fastGWA`
   - Manhattan and QQ plots
3. GenomicSEM and HDL analysis in R:
   - SNP harmonization against a HapMap reference panel
   - sumstat cleanup for Alzheimer's disease and dementia traits
   - HDL-based genetic correlation estimation

## Project Layout

```text
config/      Local configuration files
data/        Input data placeholders
figures/     Generated figures
results/     Generated tables and outputs
scripts/
  bash/      PLINK and GCTA scripts
  r/         R analysis scripts
Makefile     Convenience commands
```

## Renamed Files

- `first_part.R` -> `scripts/r/01_plot_lifespan_scatter.R`
- `second_part.r` -> `scripts/r/02_build_survival_table.R`
- `third_part.r` -> `scripts/r/03_plot_conditional_lifespan.R`
- `part_1.sh` -> `scripts/bash/01_filter_genotypes.sh`
- `part_3.sh` -> `scripts/bash/02_merge_filtered_chromosomes.sh`
- `part_4.sh` -> `scripts/bash/03_build_grm.sh`
- `part_5.sh` -> `scripts/bash/04_run_fastgwa.sh`
- `part_6.sh` -> `scripts/r/04_plot_manhattan.R`
- `part_7.sh` -> `scripts/r/05_plot_qq.R`
- GenomicSEM/HDL pipeline -> `scripts/r/06_run_genomicsem_hdl.R`

## Setup

### R packages

```r
install.packages(c("dplyr", "ggplot2", "data.table"))
```

### External software

- [PLINK 1.9](https://www.cog-genomics.org/plink/)
- [GCTA](https://yanglab.westlake.edu.cn/software/gcta/)

### Configuration

```bash
cp config/project.env.example config/project.env
```

Update `config/project.env` with local paths.

## Environment

Minimum setup:

- R 4.3 or newer
- `dplyr`
- `ggplot2`
- PLINK 1.9
- GCTA
- `data.table`
- `GenomicSEM`
- `HDL`

## Usage

### R outputs

```bash
make tables LIFESPAN_DATA=data/lifespan_data.rds
make plots LIFESPAN_DATA=data/lifespan_data.rds GWAS_DATA=results/gwas_summary_stats.tsv
```

### Genetics workflow

```bash
make qc
make merge
make grm
make gwas
```

### GenomicSEM and HDL

```bash
make genomicsem
```

### Individual scripts

```bash
Rscript scripts/r/01_plot_lifespan_scatter.R data/lifespan_data.rds figures/lifespan_scatter.png
bash scripts/bash/01_filter_genotypes.sh
```

## Notes

- Raw data and sample files are not stored in this repository.
- GWAS plotting scripts expect summary statistics with at least `CHR`, `POS`, and `P` columns.
- The GenomicSEM/HDL script expects fastGWA files with `SNP`, `CHR`, `POS`, `A1`, `A2`, `BETA`, `SE`, and `N` columns.
- The shell scripts expect genetics data folders named `Chr1` to `Chr22`, with `bestguess_chr*` and `infofile_chr*.txt` files.
- Dense GRM construction is included. Sparse GRM creation and LD pruning are not included.
