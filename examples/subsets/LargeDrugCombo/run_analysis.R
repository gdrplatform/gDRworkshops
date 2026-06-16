# Quick subset analysis: LargeDrugCombo (10 cell lines from 43)
# Run from the repository root
# NOTE: First run create_subsets.R to generate the subset data files

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

wd <- file.path(getwd(), "examples", "subsets", "LargeDrugCombo")

# Load annotations
drug_annotation <- fread(file.path(wd, "data_annotation", "drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "data_annotation", "cell_line_annotation.csv"))

# Import data (subset: 10 cell lines)
manifest <- file.path(wd, "raw_data", "manifest.xlsx")
treatment <- file.path(wd, "raw_data", "template.xlsx")
raw_data <- file.path(wd, "raw_data", list.files(file.path(wd, "raw_data"), pattern = "mtx17\\.csv$"))

data_imported <- import_data(manifest, treatment, raw_data,
                             instrument = detect_file_format(raw_data[1]),
                             cell_line_annotation = cell_line_annotation,
                             drug_annotation = drug_annotation)

# Run pipeline
mae <- runDrugResponseProcessingPipeline(data_imported)

# Explore
names(mae)
se_combo <- mae[["combination matrix"]]
assayNames(se_combo)

# Extract synergy scores
scores <- convert_mae_assay_to_dt(mae, "Scores")
synergy <- scores[, .(mean_Bliss = mean(Bliss_score, na.rm = TRUE)),
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
