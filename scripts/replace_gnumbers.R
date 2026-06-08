# Replace internal Gnumbers with open-source IDs across all raw data files
# Run this script from the repository root before re-running the pipeline

library(readxl)
library(writexl)
library(data.table)

# ==============================================================================
# Mapping: old internal Gnumber -> new open-source ID
# ==============================================================================

gnumber_map <- data.table(
  old = c("G02843881.1-7", "G02967907.1-49", "G03069545.15-4",
          "G03083045.23-1", "G00044364.1-13", "G00050939.150-10",
          "G03498025"),
  new = c("G00100", "G00101", "G00102",
          "G00103", "G00104", "G00105",
          "G00106"),
  drug_name = c("Everolimus", "Inavolisib", "Giredestrant",
                "Belvarafenib", "Vemurafenib", "Cobimetinib",
                "GDC-8025")
)
print(gnumber_map)

# ==============================================================================
# Helper: replace Gnumbers in a data.table
# ==============================================================================

replace_gnumbers_in_dt <- function(dt, map) {
  for (col in names(dt)) {
    if (is.character(dt[[col]])) {
      for (i in seq_len(nrow(map))) {
        dt[[col]] <- gsub(map$old[i], map$new[i], dt[[col]], fixed = TRUE)
      }
    }
  }
  dt
}

# ==============================================================================
# Helper: replace Gnumbers in Excel file (all sheets)
# ==============================================================================

replace_gnumbers_in_xlsx <- function(path, map) {
  sheets <- excel_sheets(path)
  result <- lapply(sheets, function(s) {
    dt <- as.data.table(read_excel(path, sheet = s, col_names = TRUE))
    replace_gnumbers_in_dt(dt, map)
  })
  names(result) <- sheets
  write_xlsx(result, path)
  message("  Updated: ", path)
}

# ==============================================================================
# SmallDrugCombo
# ==============================================================================

message("\n=== SmallDrugCombo ===")
small_dir <- file.path("examples", "SmallDrugCombo_Zhou_CellChemBio_2026")

# drug_annotation.csv
da <- fread(file.path(small_dir, "data_annotation", "drug_annotation.csv"))
da <- replace_gnumbers_in_dt(da, gnumber_map)
fwrite(da, file.path(small_dir, "data_annotation", "drug_annotation.csv"))
message("  Updated: drug_annotation.csv")

# Excel files in raw_data
xlsx_files <- list.files(file.path(small_dir, "raw_data"), pattern = "\\.xlsx$", full.names = TRUE)
for (f in xlsx_files) {
  tryCatch(
    replace_gnumbers_in_xlsx(f, gnumber_map),
    error = function(e) message("  SKIP (error): ", basename(f), " - ", e$message)
  )
}

# ==============================================================================
# LargeDrugCombo
# ==============================================================================

message("\n=== LargeDrugCombo ===")
large_dir <- file.path("examples", "LargeDrugCombo_Goetz_Cancers_2024")

# drug_annotation.csv
da <- fread(file.path(large_dir, "data_annotation", "drug_annotation.csv"))
da <- replace_gnumbers_in_dt(da, gnumber_map)
fwrite(da, file.path(large_dir, "data_annotation", "drug_annotation.csv"))
message("  Updated: drug_annotation.csv")

# Excel files
xlsx_files <- list.files(file.path(large_dir, "raw_data"), pattern = "\\.xlsx$", full.names = TRUE)
for (f in xlsx_files) {
  tryCatch(
    replace_gnumbers_in_xlsx(f, gnumber_map),
    error = function(e) message("  SKIP (error): ", basename(f), " - ", e$message)
  )
}

# CSV raw data files (plate reader)
csv_files <- list.files(file.path(large_dir, "raw_data"), pattern = "\\.csv$", full.names = TRUE)
for (f in csv_files) {
  dt <- fread(f)
  dt <- replace_gnumbers_in_dt(dt, gnumber_map)
  fwrite(dt, f)
  message("  Updated: ", basename(f))
}

# ==============================================================================
# PRISMBroadScreen
# ==============================================================================

message("\n=== PRISMBroadScreen ===")
prism_dir <- file.path("examples", "PRISMBroadScreen_Hagenbeek_NatComm_2026")

# drug_annotation.csv
da <- fread(file.path(prism_dir, "data_annotation", "drug_annotation.csv"))
da <- replace_gnumbers_in_dt(da, gnumber_map)
fwrite(da, file.path(prism_dir, "data_annotation", "drug_annotation.csv"))
message("  Updated: drug_annotation.csv")

# PRISM raw data folder name contains GDC-8025 (DrugName, not Gnumber) - no change needed
# The Gnumber G03498025 may appear inside the PRISM level5 data files
prism_data_dir <- file.path(prism_dir, "raw_data", "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025")
if (dir.exists(prism_data_dir)) {
  prism_csvs <- list.files(prism_data_dir, pattern = "\\.csv$", full.names = TRUE)
  for (f in prism_csvs) {
    dt <- fread(f)
    dt <- replace_gnumbers_in_dt(dt, gnumber_map)
    fwrite(dt, f)
    message("  Updated: ", basename(f))
  }
}

# Model.csv
model_path <- file.path(prism_dir, "raw_data", "Model.csv")
if (file.exists(model_path)) {
  dt <- fread(model_path)
  dt <- replace_gnumbers_in_dt(dt, gnumber_map)
  fwrite(dt, model_path)
  message("  Updated: Model.csv")
}

message("\n=== Done! ===")
message("Next steps:")
message("  1. Delete gDR_data/, plots/, tables/ directories (will be regenerated)")
message("  2. Re-run the gDR pipeline for each dataset")
message("  3. Commit the updated files")
