#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages(c("dplyr", "ggplot2"))

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] %||% "data/lifespan_data.rds"
output_path <- args[2] %||% "figures/conditional_lifespan.png"

lifespan_data <- read_input_table(input_path)

danish_data <- lifespan_data |>
  dplyr::filter(byear >= 1870, byear <= 1930) |>
  dplyr::group_by(newpairno) |>
  dplyr::filter(all(age > 6), all(statusnew == 1)) |>
  dplyr::ungroup()

pairs_long <- danish_data |>
  dplyr::group_by(newpairno) |>
  dplyr::mutate(cotwin_age = rev(age)) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    cotwin_age_bin = cut(
      cotwin_age,
      breaks = seq(20, 105, by = 5),
      include.lowest = TRUE,
      right = FALSE
    )
  )

conditional_means <- pairs_long |>
  dplyr::group_by(zygoti, sex, cotwin_age_bin) |>
  dplyr::summarise(
    mean_lifespan = mean(age, na.rm = TRUE),
    cotwin_mid = mean(cotwin_age, na.rm = TRUE),
    n = dplyr::n(),
    .groups = "drop"
  )

plot <- ggplot2::ggplot(
  conditional_means,
  ggplot2::aes(
    x = cotwin_mid,
    y = mean_lifespan,
    colour = factor(zygoti),
    linetype = factor(zygoti),
    group = zygoti
  )
) +
  ggplot2::geom_point(size = 2, alpha = 0.6) +
  ggplot2::geom_smooth(method = "loess", se = FALSE, span = 0.75, linewidth = 1.0) +
  ggplot2::geom_hline(yintercept = 70, linetype = "solid", color = "grey") +
  ggplot2::geom_hline(
    data = data.frame(sex = 2),
    ggplot2::aes(yintercept = 72),
    linetype = "solid",
    color = "grey"
  ) +
  ggplot2::facet_wrap(~sex, labeller = ggplot2::labeller(sex = c("1" = "Males", "2" = "Females"))) +
  ggplot2::scale_color_manual(
    values = c("1" = "blue", "2" = "red"),
    labels = c("1" = "MZ", "2" = "DZ"),
    name = "Zygosity"
  ) +
  ggplot2::scale_linetype_manual(
    values = c("1" = "solid", "2" = "dotted"),
    labels = c("1" = "MZ", "2" = "DZ"),
    name = "Zygosity"
  ) +
  ggplot2::scale_x_continuous(breaks = seq(20, 105, 10), limits = c(20, 105)) +
  ggplot2::scale_y_continuous(breaks = seq(60, 90, 10), limits = c(60, 90)) +
  ggplot2::labs(
    title = "Conditional lifespan (Danish twins, 1870-1930)",
    x = "Cotwin lifespan",
    y = "Mean lifespan"
  ) +
  ggplot2::theme_minimal(base_size = 14) +
  ggplot2::theme(legend.position = "bottom")

ensure_parent_dir(output_path)
ggplot2::ggsave(output_path, plot = plot, width = 10, height = 6, dpi = 300)
