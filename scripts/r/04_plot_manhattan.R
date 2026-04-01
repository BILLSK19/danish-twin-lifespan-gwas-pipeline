#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages(c("dplyr", "ggplot2"))

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] %||% "results/gwas_summary_stats.tsv"
output_path <- args[2] %||% "figures/manhattan_plot.png"

gwas <- read_input_table(input_path)
required_columns <- c("CHR", "POS", "P")

if (!all(required_columns %in% names(gwas))) {
  stop(sprintf("Input must contain columns: %s", paste(required_columns, collapse = ", ")))
}

gwas <- gwas |>
  dplyr::mutate(CHR = as.integer(CHR), POS = as.numeric(POS), P = as.numeric(P)) |>
  dplyr::filter(!is.na(CHR), !is.na(POS), !is.na(P), P > 0) |>
  dplyr::arrange(CHR, POS) |>
  dplyr::mutate(logP = -log10(P))

chr_len <- gwas |>
  dplyr::group_by(CHR) |>
  dplyr::summarise(len = max(POS), .groups = "drop") |>
  dplyr::mutate(offset = c(0, cumsum(head(len, -1))))

gwas <- dplyr::left_join(gwas, chr_len, by = "CHR") |>
  dplyr::mutate(BP_cum = POS + offset)

axis_df <- gwas |>
  dplyr::group_by(CHR) |>
  dplyr::summarise(center = (min(BP_cum) + max(BP_cum)) / 2, .groups = "drop")

plot <- ggplot2::ggplot(gwas, ggplot2::aes(x = BP_cum, y = logP, color = factor(CHR %% 2))) +
  ggplot2::geom_point(size = 0.8, alpha = 0.8) +
  ggplot2::scale_color_manual(values = c("0" = "#1f77b4", "1" = "#7f7f7f"), guide = "none") +
  ggplot2::scale_x_continuous(breaks = axis_df$center, labels = axis_df$CHR) +
  ggplot2::geom_hline(yintercept = -log10(5e-8), color = "red") +
  ggplot2::geom_hline(yintercept = -log10(1e-5), color = "orange") +
  ggplot2::labs(x = "Chromosome", y = expression(-log[10](italic(P)))) +
  ggplot2::theme_minimal()

ensure_parent_dir(output_path)
ggplot2::ggsave(output_path, plot = plot, width = 12, height = 5, dpi = 300)
