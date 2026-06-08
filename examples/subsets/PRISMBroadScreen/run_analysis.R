# Quick subset analysis: PRISMBroadScreen (15 cell lines from 774)
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

wd <- file.path(here::here(), "examples", "subsets", "PRISMBroadScreen")

# Load annotations
drug_annotation <- fread(file.path(wd, "drug_annotation.csv"))
cell_line_annotation <- fread(file.path(wd, "cell_line_annotation.csv"))

# Import PRISM data (subset: 15 cell lines)
data_imported <- convert_LEVEL5_prism_to_gDR_input(
  prism_data_path = file.path(wd, "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"),
  meta_data_path = file.path(wd, "Model.csv")
)
data_imported <- cleanup_metadata(data_imported,
                                  cell_line_annotation = cell_line_annotation,
                                  drug_annotation = drug_annotation)

# Run pipeline
mae <- runDrugResponseProcessingPipeline(data_imported)

# Explore
names(mae)
se_sa <- mae[["single-agent"]]
assayNames(se_sa)

# Extract metrics
metrics <- convert_mae_assay_to_dt(mae, "Metrics")
metrics_rv <- metrics[normalization_type == "RV"]
print(metrics_rv[, .(CellLineName, Tissue, x_AOC, xc50)])

# Sensitivity by tissue
ggplot(metrics_rv, aes(x = reorder(CellLineName, x_AOC), y = x_AOC, fill = Tissue)) +
  geom_col() +
  coord_flip() +
  labs(x = NULL, y = "Area Over the Curve (RV)",
       title = "GDC-8025 sensitivity (subset: 15 cell lines)") +
  theme_minimal()
