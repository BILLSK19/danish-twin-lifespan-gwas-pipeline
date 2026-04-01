`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

get_script_dir <- function() {
  file_arg <- commandArgs()[grep("^--file=", commandArgs())]
  if (length(file_arg) == 0) {
    return(getwd())
  }

  normalizePath(dirname(sub("^--file=", "", file_arg[1])), winslash = "/")
}

read_input_table <- function(path) {
  stopifnot(file.exists(path))

  if (grepl("\\.rds$", path, ignore.case = TRUE)) {
    data <- readRDS(path)
    if (!is.data.frame(data)) {
      stop("RDS file must contain a data frame.")
    }
    return(data)
  }

  if (grepl("\\.csv$", path, ignore.case = TRUE)) {
    return(read.csv(path, stringsAsFactors = FALSE))
  }

  if (grepl("\\.(tsv|txt)$", path, ignore.case = TRUE)) {
    return(read.delim(path, stringsAsFactors = FALSE))
  }

  read.table(path, header = TRUE, stringsAsFactors = FALSE)
}

ensure_parent_dir <- function(path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
}

require_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(sprintf("Missing required packages: %s", paste(missing, collapse = ", ")))
  }
}
