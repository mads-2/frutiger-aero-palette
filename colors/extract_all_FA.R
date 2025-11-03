#!/usr/bin/env Rscript
# ============================================================
# extract_all_FA.R
# ------------------------------------------------------------
# Loops over all "FA_*" directories in ./images/,
# extracts dominant colors from each .png using k-means,
# and writes one text file per image (e.g., 1color.txt).
# Compatible with current colorfindr output format
# (col_hex, col_freq, col_share).
# ============================================================

library(colorfindr)
library(dplyr)
library(magrittr)
library(grDevices)

# Parameters
base_dir      <- "images"
output_suffix <- "color.txt"
num_clusters  <- 8

# Function: extract_dominant_colors
extract_dominant_colors <- function(img_path, k = num_clusters) {
  cols <- get_colors(img_path) %>%
    mutate(hex = col_hex, freq = col_freq)
  
  rgb_mat <- t(col2rgb(cols$hex)) / 255
  df <- as.data.frame(rgb_mat) %>%
    rename(r = red, g = green, b = blue) %>%
    mutate(weight = cols$freq)
  
  # Expand rows approximately proportional to frequency
  df_expanded <- df[rep(seq_len(nrow(df)), 
                        times = pmax(1, round(df$weight / max(df$weight) * 100))), 1:3]
  
  set.seed(123)
  km <- kmeans(df_expanded, centers = k, iter.max = 200, algorithm = "Lloyd")
  
  clusters <- as.data.frame(km$centers)
  clusters$size <- as.numeric(table(km$cluster))
  clusters <- clusters %>% arrange(desc(size))
  
  rgb(clusters$r, clusters$g, clusters$b)
}

# ------------------------------------------------------------------
# Main loop over all FA_ directories and images
# ------------------------------------------------------------------
fa_dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
fa_dirs <- fa_dirs[grepl("^FA_", basename(fa_dirs))]

for (folder in fa_dirs) {
  cat("Processing folder:", folder, "\n")
  imgs <- list.files(folder, pattern = "\\.png$", full.names = TRUE)
  if (length(imgs) == 0) next
  
  for (img in imgs) {
    try({
      hex_codes <- extract_dominant_colors(img)
      out_file <- file.path(folder,
                            paste0(tools::file_path_sans_ext(basename(img)), output_suffix))
      writeLines(hex_codes, out_file)
      cat("  Wrote:", basename(out_file), "\n")
    }, silent = TRUE)
  }
}

cat("Done.\n")
