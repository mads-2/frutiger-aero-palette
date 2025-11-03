#!/usr/bin/env Rscript
# ============================================================
# cluster_FA_colors.R
# ------------------------------------------------------------
# For each FA_* directory in ./images:
#   1. Collect all hex colors from *color.txt files.
#   2. Convert to RGB coordinates in [0,1].
#   3. Weight colors by frequency of appearance.
#   4. Cluster with k-means (RGB space).
#   5. Save centroids (dominant colors) to colors.txt.
# ============================================================

library(dplyr)
library(magrittr)
library(readr)
library(grDevices)

# Parameters
base_dir     <- "images"
num_clusters <- 30     # number of clusters (output colors)

# List all FA_* folders
fa_dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
fa_dirs <- fa_dirs[grepl("^FA_", basename(fa_dirs))]

for (folder in fa_dirs) {
  aesthetic <- basename(folder)
  cat("Processing", aesthetic, "...\n")
  
  # Collect all color files
  color_files <- list.files(folder, pattern = "color\\.txt$", full.names = TRUE)
  if (length(color_files) == 0) {
    cat("  No color files found in", aesthetic, "\n")
    next
  }
  
  # Read all hex codes and build frequency table
  all_colors <- unlist(lapply(color_files, read_lines))
  all_colors <- toupper(trimws(all_colors))
  all_colors <- all_colors[all_colors != ""]
  if (length(all_colors) == 0) next
  
  color_table <- as.data.frame(table(all_colors)) %>%
    rename(hex = all_colors, freq = Freq)
  
  # Convert hex to normalized RGB
  rgb_mat <- t(col2rgb(color_table$hex)) / 255
  df <- as.data.frame(rgb_mat) %>%
    rename(r = red, g = green, b = blue) %>%
    mutate(weight = color_table$freq)
  
  # Expand rows approximately by frequency weight
  df_expanded <- df[rep(seq_len(nrow(df)),
                        times = pmax(1, round(df$weight / max(df$weight) * 100))), 1:3]
  
  # K-means clustering to find dominant aesthetic colors
  set.seed(123)
  km <- kmeans(df_expanded, centers = num_clusters, iter.max = 200, algorithm = "Lloyd")
  
  # Cluster centroids = representative colors
  clusters <- as.data.frame(km$centers)
  clusters$size <- as.numeric(table(km$cluster))
  clusters <- clusters %>% arrange(desc(size))
  
  hex_codes <- rgb(clusters$r, clusters$g, clusters$b)
  
  # Write to colors.txt inside aesthetic folder
  out_file <- file.path(folder, "colors.txt")
  writeLines(hex_codes, out_file)
  cat("  Saved", length(hex_codes), "cluster colors to", out_file, "\n")
}

cat("Done.\n")


