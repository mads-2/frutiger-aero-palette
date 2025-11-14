#!/usr/bin/env Rscript
# ============================================================
# aggregate_FA_objects.R
# ------------------------------------------------------------
# For each FA_* folder under ./images:
#   1. Reads all *object.txt files (from Google Vision API).
#   2. Cleans label text and normalizes capitalization.
#   3. Aggregates probability scores and counts per label.
#   4. Removes unwanted labels (generic or unhelpful words).
#   5. Optionally merges similar labels (placeholder section).
#   6. Saves object_instances.txt inside each FA_* folder.
# ============================================================

library(dplyr)
library(stringr)
library(readr)
library(magrittr)

base_dir <- "images"

# Words to filter out (expand as needed)
remove_terms <- c(
  "Art", "Font", "Text", "Logo", "Line", "Pattern", "Illustration", "Design",
  "Product", "Brand", "Sign", "Graphics", "Visual Arts", "Symbol", "Drawing",
  "Screenshot", "Diagram", "Clip Art", "Poster"
)

# --------------------------------------------------------------------
# Loop through each FA_* directory
# --------------------------------------------------------------------
fa_dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
fa_dirs <- fa_dirs[grepl("^FA_", basename(fa_dirs))]

for (folder in fa_dirs) {
  cat("\n Processing", folder, "...\n")

  # All *object.txt files in this folder
  obj_files <- list.files(folder, pattern = "object\\.txt$", full.names = TRUE)
  if (length(obj_files) == 0) {
    cat("   No object.txt files found — skipping.\n")
    next
  }

  # Read all files and combine
  records <- lapply(obj_files, function(file) {
    lines <- read_lines(file)
    lines <- lines[!str_detect(tolower(lines), "no labels")]
    lines <- str_trim(lines)
    lines <- lines[lines != ""]
    if (length(lines) == 0) return(NULL)

    df <- read.table(text = lines, sep = "\t", fill = TRUE,
                     col.names = c("label", "score"), stringsAsFactors = FALSE)
    suppressWarnings(df$score <- as.numeric(df$score))
    df
  }) %>% bind_rows()

  if (is.null(records) || nrow(records) == 0) {
    cat("  No valid records found — skipping.\n")
    next
  }

  # Normalize capitalization and trim
  records$label <- str_to_title(str_trim(records$label))

  # Aggregate: sum total score and count occurrences
  summary <- records %>%
    group_by(label) %>%
    summarise(
      total_score = sum(score, na.rm = TRUE),
      count = n(),
      .groups = "drop"
    ) %>%
    arrange(desc(total_score))

  # Filter unwanted generic labels
  summary <- summary %>%
    filter(!(label %in% remove_terms))

  # Placeholder: manual merge of similar labels
  # ------------------------------------------------
  # Example:
  # merges <- list(
  #   "Graphic Design" = c("Graphics", "Design"),
  #   "Sky" = c("Sky", "Cloud", "Blue Sky"),
  #   "Ocean" = c("Sea", "Water", "Ocean")
  # )
  #
  # for (main_label in names(merges)) {
  #   group <- merges[[main_label]]
  #   subset <- summary %>% filter(label %in% group)
  #   if (nrow(subset) > 0) {
  #     new_row <- data.frame(
  #       label = main_label,
  #       total_score = sum(subset$total_score),
  #       count = sum(subset$count)
  #     )
  #     summary <- summary %>%
  #       filter(!label %in% group) %>%
  #       bind_rows(new_row)
  #   }
  # }
  #
  # summary <- summary %>% arrange(desc(total_score))

  # Write results
  out_path <- file.path(folder, "object_instances.txt")
  write_lines(
    c("# Object label\tTotalScore\tCount",
      sprintf("%s\t%.3f\t%d", summary$label, summary$total_score, summary$count)),
    out_path
  )

  cat("  Wrote", nrow(summary), "unique objects →", out_path, "\n")
}

cat("\n All FA_* folders processed.\n")

