# Minimal working example: LargeDrugCombo (Goetz et al., Cancers 2024)
# Drug combination screen: Belvarafenib x Cobimetinib, Vemurafenib x Cobimetinib
# Run this script from the repository root or set wd below to the dataset path

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
  normalizePath(file.path(d, "..", "LargeDrugCombo_Goetz_Cancers_2024"))
})

# ==============================================================================
# Step 1: Import raw data
# ==============================================================================

manifest <- file.path(wd, "raw_data/Project41.Belva.S01.manifest.xlsx")
treatment <- file.path(wd, "raw_data/P41.Belva.mtx17.template.xlsx")
raw_data <- file.path(wd, "raw_data",
                      list.files(file.path(wd, "raw_data"), pattern = "mtx17\\.csv$"))

# Load annotations
drug_annotation <- fread(file.path(wd, "data_annotation/drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation/cell_line_annotation.csv"))

data_imported <- import_data(manifest, treatment, raw_data,
                             instrument = detect_file_format(raw_data[1]),
                             cell_line_annotation = cell_line_annotation,
                             drug_annotation = drug_annotation)

# ==============================================================================
# Step 2: Run gDR processing pipeline
# ==============================================================================

mae <- runDrugResponseProcessingPipeline(data_imported)

# ==============================================================================
# Step 3: Explore the MAE structure
# ==============================================================================

names(mae)
se_combo <- mae[["combination matrix"]]
assayNames(se_combo)

# Row metadata = drug combinations
head(rowData(se_combo))

# Column metadata = cell lines (43 melanoma lines)
colData(se_combo)

# ==============================================================================
# Step 4: Extract assay data as data.tables
# ==============================================================================

# Averaged dose-response (normalized values per dose point)
averaged <- convert_mae_assay_to_dt(mae, "Averaged")
averaged_combo <- averaged[!is.na(DrugName_2) & DrugName_2 != ""]
head(averaged_combo[, .(CellLineName, DrugName, DrugName_2, Concentration, Concentration_2, x)])

# Fitted metrics
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
metrics_combo <- metrics[!is.na(DrugName_2) & DrugName_2 != ""]
head(metrics_combo[, .(CellLineName, DrugName, DrugName_2, normalization_type, xc50, x_mean)])

# Synergy scores
scores <- convert_mae_assay_to_dt(mae, "Scores")
head(scores[, .(CellLineName, DrugName, DrugName_2, Bliss_score, HSA_score)])

# Excess matrix (per dose combination)
excess <- convert_mae_assay_to_dt(mae, "excess")
head(excess[, .(CellLineName, DrugName, DrugName_2, Concentration, Concentration_2, Bliss_excess)])

# ==============================================================================
# Step 5: Visualizations
# ==============================================================================

# --- Single-agent dose-response curves ---
response_data_sa <- convert_mae_assay_to_dt(mae, "Averaged")
response_data_sa <- response_data_sa[is.na(DrugName_2) | DrugName_2 == ""]
response_metrics_sa <- convert_mae_assay_to_dt(mae, "Metrics")
response_metrics_sa <- response_metrics_sa[is.na(DrugName_2) | DrugName_2 == ""]

cellline_name_vec <- sort(unique(response_metrics_sa[["CellLineName"]]))
drug_name_vec <- sort(unique(response_metrics_sa[["DrugName"]]))

# Curves grouped by drug (each line = one cell line)
curves_RV <- plot_dose_response_sa_by_CLs(
  dt_metrics = response_metrics_sa,
  dt_average = response_data_sa,
  cellline_name_vec = cellline_name_vec,
  drug_name_vec = drug_name_vec,
  normalization_type = "RV"
)
curves_RV[["Belvarafenib"]]

# --- Combo dose-response panel ---
response_metrics_excess <- convert_mae_assay_to_dt(mae, "excess")
response_metrics_scores <- convert_mae_assay_to_dt(mae, "Scores")

combo_panels <- plot_dose_response_combo_panel(
  dt_average = averaged_combo,
  dt_metrics = metrics_combo,
  dt_excess = response_metrics_excess,
  dt_scores = response_metrics_scores,
  normalization_type = "RV"
)
combo_panels[[1]]

# --- Boxplots: synergy scores across cell lines ---
bliss_by_cl <- plot_boxplot_metric_combo_by_CLs(
  dt_metrics = response_metrics_scores,
  metric = "Bliss_score",
  normalization_type = "RV"
)
bliss_by_cl

# --- Boxplots: synergy by drug combination ---
bliss_by_drug <- plot_boxplot_metric_combo_by_drugs(
  dt_metrics = response_metrics_scores,
  metric = "Bliss_score",
  normalization_type = "RV"
)
bliss_by_drug

# --- Summary: top synergistic cell lines ---
synergy_ranking <- scores[, .(
  mean_Bliss = mean(Bliss_score, na.rm = TRUE),
  mean_HSA = mean(HSA_score, na.rm = TRUE)
), by = .(CellLineName, DrugName, DrugName_2)][order(mean_Bliss)]

message("\nTop 10 most synergistic (lowest Bliss score = strongest synergy):")
print(synergy_ranking[1:10])

message("\nTop 10 most antagonistic:")
print(synergy_ranking[(.N - 9):.N])
