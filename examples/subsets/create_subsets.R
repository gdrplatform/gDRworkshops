# Create subset data for quick workshop runs
# Run from the repository root

library(data.table)
library(readxl)
library(writexl)

# ==============================================================================
# LargeDrugCombo subset (10 cell lines from 43)
# ==============================================================================

large_dir <- "examples/LargeDrugCombo_Goetz_Cancers_2024"
out_dir <- "examples/subsets/LargeDrugCombo"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Selected cell lines (well-known, diverse subtypes)
selected_cl <- c("A-375", "A2058", "SK-MEL-28", "COLO 829", "COLO 800",
                 "A-431", "HSC-1", "HT-144", "WM-266-4", "MEL-JUSO")

# Subset cell_line_annotation
cl_ann <- fread(file.path(large_dir, "data_annotation/cell_line_annotation.csv"))
cl_ann_sub <- cl_ann[CellLineName %in% selected_cl]
fwrite(cl_ann_sub, file.path(out_dir, "cell_line_annotation.csv"))

# Drug annotation (same — all 3 drugs)
file.copy(file.path(large_dir, "data_annotation/drug_annotation.csv"),
          file.path(out_dir, "drug_annotation.csv"), overwrite = TRUE)

# Read manifest to find which plates have the selected cell lines
manifest <- as.data.table(read_excel(file.path(large_dir, "raw_data/Project41.Belva.S01.manifest.xlsx")))
manifest_sub <- manifest[CellLineName %in% selected_cl]
selected_barcodes <- unique(manifest_sub$Barcode)

# Write subset manifest
write_xlsx(manifest_sub, file.path(out_dir, "manifest.xlsx"))

# Copy template (same for all plates)
file.copy(file.path(large_dir, "raw_data/P41.Belva.mtx17.template.xlsx"),
          file.path(out_dir, "template.xlsx"), overwrite = TRUE)

# Copy only the plate CSVs that contain selected cell lines
plate_files <- list.files(file.path(large_dir, "raw_data"), pattern = "mtx17\\.csv$")
for (pf in plate_files) {
  barcode <- sub("mtx17\\.csv$", "", pf)
  if (any(grepl(barcode, selected_barcodes, fixed = TRUE))) {
    file.copy(file.path(large_dir, "raw_data", pf),
              file.path(out_dir, pf), overwrite = TRUE)
  }
}

message(sprintf("LargeDrugCombo: %d cell lines, %d plates (from 43 lines, %d plates)",
                nrow(cl_ann_sub), length(list.files(out_dir, pattern = "mtx17")),
                length(plate_files)))

# ==============================================================================
# Summary
# ==============================================================================

message("\nSubsets created in examples/subsets/")
message("  LargeDrugCombo/: ", nrow(cl_ann_sub), " cell lines")
message("  PRISMBroadScreen/: already created (15 cell lines)")
message("\nSmallDrugCombo (4 cell lines) is already small enough — no subset needed.")
