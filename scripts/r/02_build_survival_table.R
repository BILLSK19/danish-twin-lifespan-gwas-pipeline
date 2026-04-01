#!/usr/bin/env Rscript

script_args <- commandArgs()
file_arg <- script_args[grep("^--file=", script_args)]
script_dir <- if (length(file_arg) == 0) getwd() else normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
source(file.path(script_dir, "utils.R"))
require_packages("dplyr")

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] %||% "data/lifespan_data.rds"
output_path <- args[2] %||% "results/table_1_survival_pairs.csv"

lifespan_data <- read_input_table(input_path)

filtered_data <- lifespan_data |>
  dplyr::filter(byear >= 1870, byear <= 1930) |>
  dplyr::group_by(newpairno) |>
  dplyr::mutate(
    both_past_6 = all(age > 6),
    none_emigrated = all(status != 80),
    both_realistic = all(age < 120)
  ) |>
  dplyr::ungroup() |>
  dplyr::filter(both_past_6, none_emigrated, both_realistic) |>
  dplyr::select(-both_past_6, -none_emigrated, -both_realistic)

age_thresholds <- c(25, 75, 85)

count_survival_pairs <- function(data, zygosity_value, sex_value, age_cutoff) {
  group_data <- data |>
    dplyr::filter(zygoti == zygosity_value, sex == sex_value) |>
    dplyr::group_by(newpairno) |>
    dplyr::summarise(
      both_survived = all(age >= age_cutoff),
      one_survived = sum(age >= age_cutoff) == 1,
      neither_survived = all(age < age_cutoff),
      .groups = "drop"
    )

  paste(
    sum(group_data$both_survived, na.rm = TRUE),
    sum(group_data$one_survived, na.rm = TRUE),
    sum(group_data$neither_survived, na.rm = TRUE),
    sep = "/"
  )
}

table_df <- data.frame(
  Age = c("25+", "75+", "85+"),
  MZm = NA_character_,
  DZm = NA_character_,
  MZf = NA_character_,
  DZf = NA_character_,
  stringsAsFactors = FALSE
)

for (i in seq_along(age_thresholds)) {
  age_cutoff <- age_thresholds[i]
  table_df$MZm[i] <- count_survival_pairs(filtered_data, 1, 1, age_cutoff)
  table_df$DZm[i] <- count_survival_pairs(filtered_data, 2, 1, age_cutoff)
  table_df$MZf[i] <- count_survival_pairs(filtered_data, 1, 2, age_cutoff)
  table_df$DZf[i] <- count_survival_pairs(filtered_data, 2, 2, age_cutoff)
}

ensure_parent_dir(output_path)
write.csv(table_df, output_path, row.names = FALSE)
print(table_df)
