SHELL := /bin/bash

LIFESPAN_DATA ?= data/lifespan_data.rds
GWAS_DATA ?= results/gwas_summary_stats.tsv

.PHONY: help plots tables qc merge grm gwas genomicsem

help:
	@printf "Targets:\n"
	@printf "  make plots   # build all R figures\n"
	@printf "  make tables  # build the survival table\n"
	@printf "  make qc      # run per-chromosome QC with PLINK\n"
	@printf "  make merge   # merge filtered chromosomes\n"
	@printf "  make grm     # build dense GRM with GCTA\n"
	@printf "  make gwas    # run fastGWA\n"

plots:
	Rscript scripts/r/01_plot_lifespan_scatter.R "$(LIFESPAN_DATA)" figures/lifespan_scatter.png
	Rscript scripts/r/03_plot_conditional_lifespan.R "$(LIFESPAN_DATA)" figures/conditional_lifespan.png
	Rscript scripts/r/04_plot_manhattan.R "$(GWAS_DATA)" figures/manhattan_plot.png
	Rscript scripts/r/05_plot_qq.R "$(GWAS_DATA)" figures/qq_plot.png

tables:
	Rscript scripts/r/02_build_survival_table.R "$(LIFESPAN_DATA)" results/table_1_survival_pairs.csv

qc:
	bash scripts/bash/01_filter_genotypes.sh

merge:
	bash scripts/bash/02_merge_filtered_chromosomes.sh

grm:
	bash scripts/bash/03_build_grm.sh

gwas:
	bash scripts/bash/04_run_fastgwa.sh


genomicsem:
	Rscript scripts/r/06_run_genomicsem_hdl.R
