# Minimal working example: LargeDrugCombo (Goetz et al., Cancers 2024)
# Drug combination screen: Belvarafenib x Cobimetinib, Vemurafenib x Cobimetinib
# Run this script from the LargeDrugCombo_Goetz_Cancers_2024/ directory

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
manifest <- file.path(wd, "raw_data/Project41.Belva.S01.manifest.xlsx")
treatment <- file.path(wd, "raw_data/P41.Belva.mtx17.template.xlsx")
raw_data <- file.path(wd, "raw_data",
                      list.files(file.path(wd, "raw_data"), pattern = "mtx17\\.csv$"))

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
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
head(metrics)

averaged <- convert_mae_assay_to_dt(mae, "Averaged")
head(averaged)

# --- Step 4: Visualize ---
# Synergy scores summary
scores <- convert_mae_assay_to_dt(mae, "Scores")
bliss_summary <- scores[, .(mean_Bliss = mean(Bliss_excess, na.rm = TRUE)),
                        by = .(CellLineName, DrugName, DrugName_2)]
print(bliss_summary[order(mean_Bliss)][1:10])

message("\nDone! The MAE object contains all processed data.")
message("Explore with: names(mae), assayNames(mae[[1]])")
