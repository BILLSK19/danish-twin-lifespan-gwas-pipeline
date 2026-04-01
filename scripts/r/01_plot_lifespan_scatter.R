#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages(c("dplyr", "ggplot2"))

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] %||% "data/lifespan_data.rds"
output_path <- args[2] %||% "figures/lifespan_scatter.png"

lifespan_data <- read_input_table(input_path)

plot_data <- dplyr::mutate(
  lifespan_data,
  age_scrambled = dplyr::case_when(
    age < 2 ~ age + stats::runif(dplyr::n(), 0, 3),
    byear < 1930 ~ age + stats::runif(dplyr::n(), -2, 2),
    byear >= 1930 ~ age + stats::runif(dplyr::n(), -1, 1),
    TRUE ~ age
  ),
  byear_scrambled = dplyr::case_when(
    byear < 1872 ~ byear + stats::runif(dplyr::n(), 0, 3),
    byear < 1930 ~ byear + stats::runif(dplyr::n(), -2, 2),
    byear >= 1930 ~ byear + stats::runif(dplyr::n(), -1, 1),
    TRUE ~ byear
  )
)

plot_data <- dplyr::filter(plot_data, !is.na(event_type), age < 120)

plot <- ggplot2::ggplot(plot_data) +
  ggplot2::geom_point(
    ggplot2::aes(x = byear_scrambled, y = age_scrambled, color = event_type),
    alpha = 0.25,
    size = 0.2
  ) +
  ggplot2::scale_color_manual(
    values = c(death = "black", censored = "blue", emigrated = "red")
  ) +
  ggplot2::scale_x_continuous(breaks = seq(1870, 2024, by = 10)) +
  ggplot2::scale_y_continuous(breaks = c(0, 6, 25, 50, 75, 100)) +
  ggplot2::geom_vline(xintercept = 1930, linetype = "dashed", color = "darkgrey") +
  ggplot2::geom_hline(yintercept = 6, linetype = "dashed", color = "darkgrey") +
  ggplot2::labs(
    title = "Lifespans of Danish Cohort",
    x = "Calendar Year",
    y = "Age (years)",
    color = NULL
  ) +
  ggplot2::theme_minimal()

ensure_parent_dir(output_path)
ggplot2::ggsave(output_path, plot = plot, width = 11, height = 6, dpi = 300)
