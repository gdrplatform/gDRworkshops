# Quick subset analysis: SmallDrugCombo (4 cell lines — full dataset)
# This is already a small dataset, so no subsetting is needed.
# Run from the repository root

library(gDR)
library(gDRimport)
library(gDRcore)
library(gDRutils)
library(gDRplots)
library(MultiAssayExperiment)
library(SummarizedExperiment)
library(qs2)
library(data.table)
library(ggplot2)

wd <- local({
  d <- tryCatch(dirname(sys.frame(1)$ofile), error = function(e) NULL)
  if (is.null(d) && requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    d <- dirname(rstudioapi::getSourceEditorContext()$path)
  if (is.null(d) || !nzchar(d))
    stop("Use source() or the Source button in RStudio to run this script.")
  normalizePath(d)
})

# Import data
manifest <- file.path(wd, "raw_data", "9545combo_Manifest.xlsx")
treatment <- file.path(wd, "raw_data", c(
  "0077_1uM_9545 combo_Treatment.xlsx",
  "0077_9545 combo_Treatment.xlsx",
  "Evero_9545 combo_Treatment.xlsx",
  "Evero1uM_9545 combo_Treatment.xlsx",
  "Untreated.xlsx"
))
raw_data <- file.path(wd, "raw_data", c(
  "9545combo_rawdata.xlsx",
  "Day0.rawdata.xlsx"
))

data_imported <- import_data(manifest, treatment, raw_data,
                             instrument = detect_file_format(raw_data[1]))

# Annotate cell lines and drugs
drug_annotation <- fread(file.path(wd, "data_annotation", "drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation", "cell_line_annotation.csv"))
data_imported <- annotate_dt_with_drug(data_imported, drug_annotation)
data_imported <- annotate_dt_with_cell_line(data_imported, cell_line_annotation)

# Run pipeline
mae <- runDrugResponseProcessingPipeline(data_imported)

# Explore
names(mae)
se_combo <- mae[["combination"]]
assayNames(se_combo)

# Synergy scores
scores <- convert_mae_assay_to_dt(mae, "scores")
synergy <- scores[, .(mean_Bliss = mean(bliss_score, na.rm = TRUE)),
                  by = .(CellLineName, DrugName, DrugName_2)]
print(synergy[order(mean_Bliss)])

# Dose-response curves
averaged <- convert_mae_assay_to_dt(mae, "Averaged")
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
sa_avg <- averaged[is.na(DrugName_2) | DrugName_2 == ""]
sa_met <- metrics[is.na(DrugName_2) | DrugName_2 == ""]

curves <- plot_dose_response_sa_by_CLs(
  dt_metrics = sa_met, dt_average = sa_avg,
  cellline_name_vec = sort(unique(sa_met$CellLineName)),
  drug_name_vec = sort(unique(sa_met$DrugName)),
  normalization_type = "RV"
)
curves[[1]]
