# Danish Twin Lifespan and GWAS Pipeline

![R](https://img.shields.io/badge/R-analysis-276DC3?logo=r&logoColor=white) ![PLINK](https://img.shields.io/badge/PLINK-1.9-0A7F8C) ![GCTA](https://img.shields.io/badge/GCTA-fastGWA-4C956C) ![License](https://img.shields.io/badge/license-MIT-black)

A reproducible analysis repository for Danish twin lifespan research and downstream GWAS. The project combines descriptive survival analyses in R with genotype QC, GRM construction, and association testing using PLINK and GCTA.

Core outputs include:

- lifespan and conditional cotwin lifespan figures
- a survival-threshold summary table for twin pairs
- Manhattan and QQ plots from GWAS summary statistics
- reusable shell entry points for chromosome-level QC, merging, GRM construction, and `fastGWA`

## What The Project Does

The repository includes two connected pieces of work:

1. It analyzes twin lifespan data from a Danish cohort by:
   - plotting lifespan trajectories over birth year with age/year jittering for de-identification
   - counting twin pairs where both, one, or neither twin survives past key age thresholds
   - plotting conditional lifespan as a function of cotwin lifespan by sex and zygosity
2. It runs a GWAS-style genetics workflow by:
   - filtering chromosome-level genotype data with PLINK
   - merging filtered chromosomes into a genome-wide dataset
   - building a genomic relationship matrix with GCTA
   - running `fastGWA`
   - plotting Manhattan and QQ summaries from association results

## Project Layout

```text
config/      Environment-specific paths and tool configuration
data/        Input data placeholders (ignored by Git)
figures/     Generated plots (ignored by Git)
results/     Generated tables and GWAS outputs (ignored by Git)
scripts/
  bash/      PLINK and GCTA pipeline steps
  r/         Analysis and plotting scripts
Makefile     Convenience commands for common tasks
```

## Renamed Files

The original numbered fragments were renamed into descriptive files:

- `first_part.R` -> `scripts/r/01_plot_lifespan_scatter.R`
- `second_part.r` -> `scripts/r/02_build_survival_table.R`
- `third_part.r` -> `scripts/r/03_plot_conditional_lifespan.R`
- `part_1.sh` -> `scripts/bash/01_filter_genotypes.sh`
- `part_3.sh` -> `scripts/bash/02_merge_filtered_chromosomes.sh`
- `part_4.sh` -> `scripts/bash/03_build_grm.sh`
- `part_5.sh` -> `scripts/bash/04_run_fastgwa.sh`
- `part_6.sh` -> `scripts/r/04_plot_manhattan.R`
- `part_7.sh` -> `scripts/r/05_plot_qq.R`

## Setup

### R dependencies

Install the packages used by the R scripts:

```r
install.packages(c("dplyr", "ggplot2"))
```

### External tools

The genetics pipeline expects:

- [PLINK 1.9](https://www.cog-genomics.org/plink/)
- [GCTA](https://yanglab.westlake.edu.cn/software/gcta/)

### Environment configuration

Copy the example config and update the absolute paths:

```bash
cp config/project.env.example config/project.env
```

## Reproducibility

This repository is organized to run from a clean clone with local path configuration stored in `config/project.env`. A minimal working environment is:

- R 4.3 or newer
- `dplyr`
- `ggplot2`
- PLINK 1.9 available on `PATH` or configured in `project.env`
- GCTA available on `PATH` or configured in `project.env`

Generated outputs are written to `figures/` and `results/`, while large input datasets remain outside version control.

## Usage

### Build the descriptive outputs

```bash
make tables LIFESPAN_DATA=data/lifespan_data.rds
make plots LIFESPAN_DATA=data/lifespan_data.rds GWAS_DATA=results/gwas_summary_stats.tsv
```

### Run the genetics pipeline

```bash
make qc
make merge
make grm
make gwas
```

You can also run scripts individually, for example:

```bash
Rscript scripts/r/01_plot_lifespan_scatter.R data/lifespan_data.rds figures/lifespan_scatter.png
bash scripts/bash/01_filter_genotypes.sh
```

## Assumptions And Gaps

- Raw data and sample files are not stored in this repository.
- The GWAS plotting scripts assume summary statistics contain at least `CHR`, `POS`, and `P`.
- The shell scripts now use config-driven paths, but they still depend on your local genetics data layout matching the original folder naming convention (`Chr1` to `Chr22`, `bestguess_chr*`, `infofile_chr*.txt`).
- A dense GRM build is included because that was present in the original scripts, but sparse GRM creation or LD pruning steps are not implemented here.
