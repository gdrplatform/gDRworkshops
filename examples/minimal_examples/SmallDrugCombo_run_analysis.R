# Minimal working example: SmallDrugCombo (Zhou et al., Cell Chem Bio 2026)
# Drug combination screen: Inavolisib x Giredestrant, Everolimus x Giredestrant
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
  normalizePath(file.path(d, "..", "SmallDrugCombo_Zhou_CellChemBio_2026"))
})

# ==============================================================================
# Step 1: Import raw data
# ==============================================================================

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

# Annotate cell lines and drugs
drug_annotation <- fread(file.path(wd, "data_annotation/drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation/cell_line_annotation.csv"))
data_imported <- annotate_dt_with_drug(data_imported, drug_annotation)
data_imported <- annotate_dt_with_cell_line(data_imported, cell_line_annotation)

# ==============================================================================
# Step 2: Run gDR processing pipeline
# ==============================================================================

mae <- runDrugResponseProcessingPipeline(data_imported)

# ==============================================================================
# Step 3: Explore the MultiAssayExperiment (MAE) structure
# ==============================================================================

# What experiments are in the MAE?
names(mae)

# Get the combo SummarizedExperiment
se_combo <- mae[["combination"]]

# What assays are available?
assayNames(se_combo)

# Row metadata = drug combinations
head(rowData(se_combo))

# Column metadata = cell lines
colData(se_combo)

# ==============================================================================
# Step 4: Extract assay data as data.tables
# ==============================================================================

# Averaged dose-response data (normalized values per dose)
averaged <- convert_mae_assay_to_dt(mae, "Averaged")
head(averaged[, .(CellLineName, DrugName, DrugName_2, Concentration, Concentration_2, x)])

# Fitted metrics (IC50, Emax, etc.)
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
head(metrics[, .(CellLineName, DrugName, DrugName_2, normalization_type, xc50, x_mean, x_AOC)])

# Synergy scores (Bliss, HSA)
scores <- convert_mae_assay_to_dt(mae, "scores")
head(scores[, .(CellLineName, DrugName, DrugName_2, bliss_score, hsa_score)])

# Excess over Bliss/HSA per dose combination
excess <- convert_mae_assay_to_dt(mae, "excess")
head(excess[, .(CellLineName, DrugName, DrugName_2, Concentration, Concentration_2, Bliss_excess)])

# ==============================================================================
# Step 5: Visualizations
# ==============================================================================

# --- Single-agent dose-response curves by cell line ---
sa_name <- get_supported_experiments("sa")
se_sa <- mae[[sa_name]]
response_data_sa <- convert_mae_assay_to_dt(mae, "Averaged")
response_data_sa <- response_data_sa[is.na(DrugName_2) | DrugName_2 == ""]
response_metrics_sa <- convert_mae_assay_to_dt(mae, "Metrics")
response_metrics_sa <- response_metrics_sa[is.na(DrugName_2) | DrugName_2 == ""]

cellline_name_vec <- sort(unique(response_metrics_sa[["CellLineName"]]))
drug_name_vec <- sort(unique(response_metrics_sa[["DrugName"]]))

# Dose-response curves: each plot = one drug, lines = cell lines
curves_RV <- plot_dose_response_sa_by_CLs(
  dt_metrics = response_metrics_sa,
  dt_average = response_data_sa,
  cellline_name_vec = cellline_name_vec,
  drug_name_vec = drug_name_vec,
  normalization_type = "RV"
)
curves_RV[[1]]

# --- Combo synergy: isobologram-style heatmaps ---
combo_name <- get_supported_experiments("combo")
response_data_combo <- convert_mae_assay_to_dt(mae, "Averaged")
response_data_combo <- response_data_combo[!is.na(DrugName_2) & DrugName_2 != ""]
response_metrics_combo <- convert_mae_assay_to_dt(mae, "Metrics")
response_metrics_combo <- response_metrics_combo[!is.na(DrugName_2) & DrugName_2 != ""]
response_metrics_excess <- convert_mae_assay_to_dt(mae, "excess")
response_metrics_scores <- convert_mae_assay_to_dt(mae, "scores")

# Combo dose-response panel for one cell line
combo_panels <- plot_dose_response_combo_panel(
  dt_average = response_data_combo,
  dt_metrics = response_metrics_combo,
  dt_excess = response_metrics_excess,
  dt_scores = response_metrics_scores,
  normalization_type = "RV"
)
combo_panels[[1]]

# --- Boxplot of synergy scores across cell lines ---
bliss_by_cl <- plot_boxplot_metric_combo_by_CLs(
  dt_metrics = response_metrics_scores,
  metric = "bliss_score",
  normalization_type = "RV"
)
bliss_by_cl

# --- Summary: which combinations are synergistic? ---
synergy_summary <- scores[, .(
  mean_Bliss = mean(bliss_score, na.rm = TRUE),
  mean_HSA = mean(hsa_score, na.rm = TRUE)
), by = .(CellLineName, DrugName, DrugName_2)]
print(synergy_summary[order(mean_Bliss)])

message("\nDone! Explore further with assayNames(se_combo) and convert_mae_assay_to_dt()")
