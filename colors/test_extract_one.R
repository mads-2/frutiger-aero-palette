#!/usr/bin/env Rscript
# ============================================================
# test_extract_one.R
# ------------------------------------------------------------
# Extracts dominant colors from one test image using k-means
# clustering in RGB space, based on colorfindr output.
# Uses 'col_hex', 'col_freq', 'col_share' columns.
# ============================================================

library(colorfindr)
library(dplyr)
library(magrittr)
library(grDevices)

# Parameters
img_path <- "images/FA_classic/1.png"
output_suffix <- "color.txt"
num_clusters  <- 8

# Function: extract_dominant_colors
extract_dominant_colors <- function(img_path, k = num_clusters) {
  cols <- get_colors(img_path) %>%
    mutate(hex = col_hex,
           freq = col_freq)
  
  # Convert hex codes to normalized RGB (0–1)
  rgb_mat <- t(col2rgb(cols$hex)) / 255
  df <- as.data.frame(rgb_mat) %>%
    rename(r = red, g = green, b = blue) %>%
    mutate(weight = cols$freq)
  
  # Expand rows by weight to emphasize frequent colors
  df_expanded <- df[rep(seq_len(nrow(df)), times = pmax(1, round(df$weight / max(df$weight) * 100))), 1:3]
  
  set.seed(123)
  km <- kmeans(df_expanded, centers = k, iter.max = 50)
  
  # Cluster summary
  clusters <- as.data.frame(km$centers)
  clusters$size <- as.numeric(table(km$cluster))
  clusters <- clusters %>% arrange(desc(size))
  
  rgb(clusters$r, clusters$g, clusters$b)
}

# Run
if (!file.exists(img_path)) stop("Image not found at: ", img_path)

hex_codes <- extract_dominant_colors(img_path)
print(hex_codes)

out_file <- file.path(dirname(img_path),
                      paste0(tools::file_path_sans_ext(basename(img_path)), output_suffix))
writeLines(hex_codes, out_file)
cat("Wrote color codes to:", out_file, "\n")


