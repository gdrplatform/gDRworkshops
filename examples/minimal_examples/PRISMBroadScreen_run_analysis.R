# Minimal working example: PRISMBroadScreen (Hagenbeek et al., Nat Commun 2026)
# Single-agent broad screen: GDC-8025 (TEAD inhibitor) across 774 cell lines
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

wd <- file.path(getwd(), "examples", "PRISMBroadScreen_Hagenbeek_NatComm_2026")

# ==============================================================================
# Step 1: Import PRISM data
# ==============================================================================

# Load annotations
drug_annotation <- fread(file.path(wd, "data_annotation/drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation/cell_line_annotation.csv"))

data_imported <- convert_LEVEL5_prism_to_gDR_input(
  prism_data_path = file.path(wd, "raw_data/CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"),
  meta_data_path = file.path(wd, "raw_data/Model.csv")
)
data_imported <- cleanup_metadata(data_imported,
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
se_sa <- mae[["single-agent"]]
assayNames(se_sa)

# Row metadata = drugs
rowData(se_sa)

# Column metadata = cell lines (774 pan-cancer)
head(colData(se_sa))

# ==============================================================================
# Step 4: Extract assay data as data.tables
# ==============================================================================

# Averaged dose-response (normalized values per dose point)
averaged <- convert_mae_assay_to_dt(mae, "Averaged")
head(averaged[, .(CellLineName, Tissue, DrugName, Concentration, x)])

# Fitted metrics (IC50, Emax, AOC, etc.)
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
metrics_rv <- metrics[normalization_type == "RV"]
head(metrics_rv[, .(CellLineName, Tissue, DrugName, xc50, x_mean, x_AOC, x_AOC_range)])

# ==============================================================================
# Step 5: Visualizations
# ==============================================================================

# --- Dose-response curves grouped by drug (subset of cell lines) ---
cellline_name_vec <- sort(unique(metrics_rv[["CellLineName"]]))
drug_name_vec <- sort(unique(metrics_rv[["DrugName"]]))

curves_RV <- plot_dose_response_sa_by_CLs(
  dt_metrics = metrics_rv,
  dt_average = averaged,
  cellline_name_vec = cellline_name_vec[1:20],
  drug_name_vec = drug_name_vec,
  normalization_type = "RV"
)
curves_RV[[1]]

# --- Dose-response curves by individual cell line ---
curves_by_drug <- plot_dose_response_sa_by_drugs(
  dt_metrics = metrics_rv,
  dt_average = averaged,
  cellline_name_vec = cellline_name_vec[1:6],
  drug_name_vec = drug_name_vec,
  normalization_type = "RV"
)
curves_by_drug[[1]]

# --- Boxplot of metrics across cell lines ---
boxplot_aoc <- plot_boxplot_metric_sa_by_CLs(
  dt_metrics = metrics_rv,
  metric = "x_AOC",
  normalization_type = "RV"
)
boxplot_aoc

# --- Top 20 most sensitive cell lines (by AOC) ---
top_sensitive <- metrics_rv[order(x_AOC, decreasing = TRUE)][1:20]
print(top_sensitive[, .(CellLineName, Tissue, x_AOC, xc50, x_mean)])

# --- Top 20 most resistant cell lines ---
top_resistant <- metrics_rv[order(x_AOC)][1:20]
print(top_resistant[, .(CellLineName, Tissue, x_AOC, xc50, x_mean)])

# --- Distribution of sensitivity across tissues ---
tissue_summary <- metrics_rv[, .(
  median_AOC = median(x_AOC, na.rm = TRUE),
  median_IC50 = median(xc50, na.rm = TRUE),
  n_lines = .N
), by = Tissue][order(-median_AOC)]
print(tissue_summary[n_lines >= 5])

# --- Sensitivity distribution by tissue (ggplot) ---
top_tissues <- tissue_summary[n_lines >= 10, Tissue]
ggplot(metrics_rv[Tissue %in% top_tissues],
       aes(x = reorder(Tissue, x_AOC, FUN = median), y = x_AOC)) +
  geom_boxplot(fill = "#129bb3", alpha = 0.6, outlier.size = 0.5) +
  coord_flip() +
  labs(x = NULL, y = "Area Over the Curve (RV)",
       title = "GDC-8025 sensitivity across tissues") +
  theme_minimal()

message("\nDone! Explore further with assayNames(se_sa) and convert_mae_assay_to_dt()")
