# Minimal working example: SmallDrugCombo (Zhou et al., Cell Chem Bio 2026)
# Drug combination screen: Inavolisib x Giredestrant, Everolimus x Giredestrant
# Run this script from the SmallDrugCombo_Zhou_CellChemBio_2026/ directory

library(gDR)
library(gDRimport)
library(gDRcore)
library(gDRutils)
library(gDRplots)
library(qs2)
library(data.table)
library(ggplot2)

wd <- here::here()

# --- Step 1: Import raw data ---
manifest <- file.path(wd, "raw_data/9545combo_Manifest.xlsx")
treatment <- file.path(wd, c(
  "raw_data/0077_1uM_9545 combo_Treatment.xlsx",
  "raw_data/0077_9545 combo_Treatment.xlsx",
  "raw_data/Evero_9545 combo_Treatment.xlsx",
  "raw_data/Evero1uM_9545 combo_Treatment.xlsx",
  "raw_data/Untreated.xlsx"
))
raw_data <- file.path(wd, c(
  "raw_data/9545combo_rawdata.xlsx",
  "raw_data/Day0.rawdata.xlsx"
))

data_imported <- import_data(manifest, treatment, raw_data,
                             instrument = detect_file_format(raw_data[1]))

# Annotate with drug and cell line metadata
drug_annotation <- fread(file.path(wd, "data_annotation/drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation/cell_line_annotation.csv"))
data_imported <- annotate_dt_with_drug(data_imported, drug_annotation)
data_imported <- annotate_dt_with_cell_line(data_imported, cell_line_annotation)

# --- Step 2: Run gDR processing pipeline ---
mae <- runDrugResponseProcessingPipeline(data_imported)

# --- Step 3: Explore results ---
# Extract combo assay metrics
se_combo <- mae[["combination matrix"]]
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
head(metrics)

# Extract averaged dose-response data
averaged <- convert_mae_assay_to_dt(mae, "Averaged")
head(averaged)

# --- Step 4: Visualize ---
# Dose-response heatmap for one combination
plot_combo_heatmap <- function(mae, cell_line, drug1, drug2, metric = "Bliss_excess") {
  se <- mae[["combination matrix"]]
  dt <- convert_mae_assay_to_dt(mae, "Scores")
  dt_sub <- dt[CellLineName == cell_line &
                 DrugName == drug1 & DrugName_2 == drug2]
  if (nrow(dt_sub) > 0) {
    message(sprintf("Bliss excess scores for %s (%s x %s):", cell_line, drug1, drug2))
    print(dt_sub[, .(Concentration, Concentration_2, Bliss_excess)])
  }
  invisible(dt_sub)
}

plot_combo_heatmap(mae, "MCF-7", "Inavolisib", "Giredestrant")

message("\nDone! The MAE object contains all processed data.")
message("Explore with: names(mae), assayNames(mae[[1]])")
