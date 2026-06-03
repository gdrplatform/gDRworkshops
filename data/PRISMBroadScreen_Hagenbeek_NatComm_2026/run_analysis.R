# Minimal working example: PRISMBroadScreen (Hagenbeek et al., Nat Commun 2026)
# Single-agent broad screen: GDC-8025 (TEAD inhibitor) across 774 cell lines
# Run this script from the PRISMBroadScreen_Hagenbeek_NatComm_2026/ directory

library(gDR)
library(gDRimport)
library(gDRcore)
library(gDRutils)
library(gDRplots)
library(qs2)
library(data.table)
library(ggplot2)

wd <- here::here()

# --- Step 1: Import PRISM data ---
data_imported <- convert_LEVEL5_prism_to_gDR_input(
  prism_data_path = file.path(wd, "raw_data/CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"),
  meta_data_path = file.path(wd, "raw_data/Model.csv")
)
data_imported <- cleanup_metadata(data_imported)

# Annotate with drug and cell line metadata
drug_annotation <- fread(file.path(wd, "data_annotation/drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation/cell_line_annotation.csv"))
data_imported <- annotate_dt_with_drug(data_imported, drug_annotation)
data_imported <- annotate_dt_with_cell_line(data_imported, cell_line_annotation)

# --- Step 2: Run gDR processing pipeline ---
mae <- runDrugResponseProcessingPipeline(data_imported)

# --- Step 3: Explore results ---
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
head(metrics)

# --- Step 4: Visualize ---
# Top sensitive cell lines by IC50
metrics_rv <- metrics[normalization_type == "RV"]
top_sensitive <- metrics_rv[order(x_AOC, decreasing = TRUE)][1:20]
print(top_sensitive[, .(CellLineName, Tissue, x_AOC, xc50)])

# Distribution of sensitivity across tissues
tissue_summary <- metrics_rv[, .(
  median_AOC = median(x_AOC, na.rm = TRUE),
  n_lines = .N
), by = Tissue][order(-median_AOC)]
print(tissue_summary[n_lines >= 5])

message("\nDone! The MAE object contains all processed data.")
message("Explore with: names(mae), assayNames(mae[[1]])")
