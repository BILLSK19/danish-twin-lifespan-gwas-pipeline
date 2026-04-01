#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages("ggplot2")

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] %||% "results/gwas_summary_stats.tsv"
output_path <- args[2] %||% "figures/qq_plot.png"

gwas <- read_input_table(input_path)

if (!"P" %in% names(gwas)) {
  stop("Input must contain a P column.")
}

observed <- -log10(sort(gwas$P[gwas$P > 0]))
expected <- -log10(stats::ppoints(length(observed)))
qq_df <- data.frame(expected = expected, observed = observed)

plot <- ggplot2::ggplot(qq_df, ggplot2::aes(x = expected, y = observed)) +
  ggplot2::geom_point(size = 0.8, alpha = 0.7) +
  ggplot2::geom_abline(intercept = 0, slope = 1, color = "red") +
  ggplot2::labs(x = "Expected -log10(P)", y = "Observed -log10(P)") +
  ggplot2::theme_minimal()

ensure_parent_dir(output_path)
ggplot2::ggsave(output_path, plot = plot, width = 6, height = 6, dpi = 300)
