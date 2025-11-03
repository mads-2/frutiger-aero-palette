#!/usr/bin/env Rscript
# collect_colors.R
# -----------------
# Reads colors.txt files under ~/bios611project/images/FA_* directories
# and outputs a JavaScript object definition for embedding in prototype.html.

library(jsonlite)

# Base path to your FA_* folders
base <- "~/bios611project/images"

# List all FA_* directories (not recursive)
dirs <- list.dirs(base, full.names = TRUE, recursive = FALSE)

data <- list()

for (d in dirs) {
  if (grepl("FA_", basename(d))) {
    color_file <- file.path(d, "colors.txt")
    if (file.exists(color_file)) {
      colors <- trimws(readLines(color_file))
      colors <- colors[nzchar(colors) & grepl("^#", colors)]  # keep only hex lines
      key <- sub("^FA_", "", basename(d))                     # remove FA_ prefix (optional)
      data[[key]] <- list(colors = colors)
    }
  }
}

# Convert to JSON -> JavaScript variable
js <- toJSON(data, pretty = TRUE, auto_unbox = TRUE)
cat("const aesthetics = ", js, ";", sep = "")

