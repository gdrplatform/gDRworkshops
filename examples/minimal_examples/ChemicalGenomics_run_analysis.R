# Minimal working example: ChemicalGenomics (Hagenbeek et al., Nature Cancer 2023)
# Anchored combination / chemical-genomics screen: a ~747-compound library tested
# against a fixed dose of the KRAS-G12C inhibitor sotorasib in NCI-H23 and NCI-H358.
# Run this script from the repository root or set wd below to the dataset path.

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
  if (is.null(d)) {
    f <- sub("--file=", "", commandArgs(FALSE)[grep("--file=", commandArgs(FALSE))])
    if (length(f) > 0 && nzchar(f)) d <- dirname(f)
  }
  if (is.null(d) && requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    d <- dirname(rstudioapi::getSourceEditorContext()$path)
  if (is.null(d) || !nzchar(d))
    stop("Cannot determine script directory. Run via source(), Rscript, or Source button.")
  normalizePath(file.path(d, "..", "ChemicalGenomics_Hagenbeek_NatCancer_2023"))
})

# ==============================================================================
# Step 1: Import raw data
# ==============================================================================

manifest <- file.path(wd, "raw_data/2021.01.13_P22_QCS-35615.manifest.xlsx")
treatment <- file.path(wd, c(
  "raw_data/Project22.Dosing1.template.xlsx",
  "raw_data/Project22.Dosing10.template.xlsx",
  "raw_data/Project22.Dosing10combo.template.xlsx",
  "raw_data/Project22.Dosing11.template.xlsx",
  "raw_data/Project22.Dosing11combo.template.xlsx",
  "raw_data/Project22.Dosing12.template.xlsx",
  "raw_data/Project22.Dosing12combo.template.xlsx",
  "raw_data/Project22.Dosing13.template.xlsx",
  "raw_data/Project22.Dosing13combo.template.xlsx",
  "raw_data/Project22.Dosing14.template.xlsx",
  "raw_data/Project22.Dosing14combo.template.xlsx",
  "raw_data/Project22.Dosing15.template.xlsx",
  "raw_data/Project22.Dosing15combo.template.xlsx",
  "raw_data/Project22.Dosing16.template.xlsx",
  "raw_data/Project22.Dosing16combo.template.xlsx",
  "raw_data/Project22.Dosing17.template.xlsx",
  "raw_data/Project22.Dosing17combo.template.xlsx",
  "raw_data/Project22.Dosing18.template.xlsx",
  "raw_data/Project22.Dosing18combo.template.xlsx",
  "raw_data/Project22.Dosing19.template.xlsx",
  "raw_data/Project22.Dosing19combo.template.xlsx",
  "raw_data/Project22.Dosing1combo.template.xlsx",
  "raw_data/Project22.Dosing2.template.xlsx",
  "raw_data/Project22.Dosing20.template.xlsx",
  "raw_data/Project22.Dosing20combo.template.xlsx",
  "raw_data/Project22.Dosing21.template.xlsx",
  "raw_data/Project22.Dosing21combo.template.xlsx",
  "raw_data/Project22.Dosing22.template.xlsx",
  "raw_data/Project22.Dosing22combo.template.xlsx",
  "raw_data/Project22.Dosing23.template.xlsx",
  "raw_data/Project22.Dosing23combo.template.xlsx",
  "raw_data/Project22.Dosing24.template.xlsx",
  "raw_data/Project22.Dosing24combo.template.xlsx",
  "raw_data/Project22.Dosing25.template.xlsx",
  "raw_data/Project22.Dosing25combo.template.xlsx",
  "raw_data/Project22.Dosing26.template.xlsx",
  "raw_data/Project22.Dosing26combo.template.xlsx",
  "raw_data/Project22.Dosing27.template.xlsx",
  "raw_data/Project22.Dosing27combo.template.xlsx",
  "raw_data/Project22.Dosing28.template.xlsx",
  "raw_data/Project22.Dosing28combo.template.xlsx",
  "raw_data/Project22.Dosing29.template.xlsx",
  "raw_data/Project22.Dosing29combo.template.xlsx",
  "raw_data/Project22.Dosing2combo.template.xlsx",
  "raw_data/Project22.Dosing3.template.xlsx",
  "raw_data/Project22.Dosing30.template.xlsx",
  "raw_data/Project22.Dosing30combo.template.xlsx",
  "raw_data/Project22.Dosing31.template.xlsx",
  "raw_data/Project22.Dosing31combo.template.xlsx",
  "raw_data/Project22.Dosing32.template.xlsx",
  "raw_data/Project22.Dosing32combo.template.xlsx",
  "raw_data/Project22.Dosing33.template.xlsx",
  "raw_data/Project22.Dosing33combo.template.xlsx",
  "raw_data/Project22.Dosing34.template.xlsx",
  "raw_data/Project22.Dosing34combo.template.xlsx",
  "raw_data/Project22.Dosing35.template.xlsx",
  "raw_data/Project22.Dosing35combo.template.xlsx",
  "raw_data/Project22.Dosing3combo.template.xlsx",
  "raw_data/Project22.Dosing4.template.xlsx",
  "raw_data/Project22.Dosing4combo.template.xlsx",
  "raw_data/Project22.Dosing5.template.xlsx",
  "raw_data/Project22.Dosing5combo.template.xlsx",
  "raw_data/Project22.Dosing6.template.xlsx",
  "raw_data/Project22.Dosing6combo.template.xlsx",
  "raw_data/Project22.Dosing7.template.xlsx",
  "raw_data/Project22.Dosing7combo.template.xlsx",
  "raw_data/Project22.Dosing8.template.xlsx",
  "raw_data/Project22.Dosing8combo.template.xlsx",
  "raw_data/Project22.Dosing9.template.xlsx",
  "raw_data/Project22.Dosing9combo.template.xlsx"
))
raw_data <- file.path(wd, c(
  "raw_data/C0112160D01.csv",
  "raw_data/C0112160D02.csv",
  "raw_data/C0112160D03.csv",
  "raw_data/C0112160D04.csv",
  "raw_data/C0112160D05.csv",
  "raw_data/C0112160D06.csv",
  "raw_data/C0112160D07.csv",
  "raw_data/C0112160D08.csv",
  "raw_data/C0112160D09.csv",
  "raw_data/C0112160D10.csv",
  "raw_data/C0112160D11.csv",
  "raw_data/C0112160D12.csv",
  "raw_data/C0112160D13.csv",
  "raw_data/C0112160D14.csv",
  "raw_data/C0112160D15.csv",
  "raw_data/C0112160D16.csv",
  "raw_data/C0112160D17.csv",
  "raw_data/C0112160D18.csv",
  "raw_data/C0112160D19.csv",
  "raw_data/C0112160D20.csv",
  "raw_data/C0112160D21.csv",
  "raw_data/C0112160D22.csv",
  "raw_data/C0112160D23.csv",
  "raw_data/C0112160D24.csv",
  "raw_data/C0112160D25.csv",
  "raw_data/C0112160D26.csv",
  "raw_data/C0112160D27.csv",
  "raw_data/C0112160D28.csv",
  "raw_data/C0112160D29.csv",
  "raw_data/C0112160D30.csv",
  "raw_data/C0112160D31.csv",
  "raw_data/C0112160D32.csv",
  "raw_data/C0112160D33.csv",
  "raw_data/C0112160D34.csv",
  "raw_data/C0112160D35.csv",
  "raw_data/C0312160D01.csv",
  "raw_data/C0312160D02.csv",
  "raw_data/C0312160D03.csv",
  "raw_data/C0312160D04.csv",
  "raw_data/C0312160D05.csv",
  "raw_data/C0312160D06.csv",
  "raw_data/C0312160D07.csv",
  "raw_data/C0312160D08.csv",
  "raw_data/C0312160D09.csv",
  "raw_data/C0312160D10.csv",
  "raw_data/C0312160D11.csv",
  "raw_data/C0312160D12.csv",
  "raw_data/C0312160D13.csv",
  "raw_data/C0312160D14.csv",
  "raw_data/C0312160D15.csv",
  "raw_data/C0312160D16.csv",
  "raw_data/C0312160D17.csv",
  "raw_data/C0312160D18.csv",
  "raw_data/C0312160D19.csv",
  "raw_data/C0312160D20.csv",
  "raw_data/C0312160D21.csv",
  "raw_data/C0312160D22.csv",
  "raw_data/C0312160D23.csv",
  "raw_data/C0312160D24.csv",
  "raw_data/C0312160D25.csv",
  "raw_data/C0312160D26.csv",
  "raw_data/C0312160D27.csv",
  "raw_data/C0312160D28.csv",
  "raw_data/C0312160D29.csv",
  "raw_data/C0312160D30.csv",
  "raw_data/C0312160D31.csv",
  "raw_data/C0312160D32.csv",
  "raw_data/C0312160D33.csv",
  "raw_data/C0312160D34.csv",
  "raw_data/C0312160D35.csv",
  "raw_data/C0501131D01.csv",
  "raw_data/C0501131D02.csv",
  "raw_data/C0501131D03.csv",
  "raw_data/C0501131D04.csv",
  "raw_data/C0501131D05.csv",
  "raw_data/C0501131D06.csv",
  "raw_data/C0501131D07.csv",
  "raw_data/C0501131D08.csv",
  "raw_data/C0501131D09.csv",
  "raw_data/C0501131D10.csv",
  "raw_data/C0501131D11.csv",
  "raw_data/C0501131D12.csv",
  "raw_data/C0501131D13.csv",
  "raw_data/C0501131D14.csv",
  "raw_data/C0501131D15.csv",
  "raw_data/C0501131D16.csv",
  "raw_data/C0501131D17.csv",
  "raw_data/C0501131D18.csv",
  "raw_data/C0501131D19.csv",
  "raw_data/C0501131D20.csv",
  "raw_data/C0501131D21.csv",
  "raw_data/C0501131D22.csv",
  "raw_data/C0501131D23.csv",
  "raw_data/C0501131D24.csv",
  "raw_data/C0501131D25.csv",
  "raw_data/C0501131D26.csv",
  "raw_data/C0501131D27.csv",
  "raw_data/C0501131D28.csv",
  "raw_data/C0501131D29.csv",
  "raw_data/C0501131D30.csv",
  "raw_data/C0501131D31.csv",
  "raw_data/C0501131D32.csv",
  "raw_data/C0501131D33.csv",
  "raw_data/C0501131D34.csv",
  "raw_data/C0501131D35.csv",
  "raw_data/C0701131D01.csv",
  "raw_data/C0701131D02.csv",
  "raw_data/C0701131D03.csv",
  "raw_data/C0701131D04.csv",
  "raw_data/C0701131D05.csv",
  "raw_data/C0701131D06.csv",
  "raw_data/C0701131D07.csv",
  "raw_data/C0701131D08.csv",
  "raw_data/C0701131D09.csv",
  "raw_data/C0701131D10.csv",
  "raw_data/C0701131D11.csv",
  "raw_data/C0701131D12.csv",
  "raw_data/C0701131D13.csv",
  "raw_data/C0701131D14.csv",
  "raw_data/C0701131D15.csv",
  "raw_data/C0701131D16.csv",
  "raw_data/C0701131D17.csv",
  "raw_data/C0701131D18.csv",
  "raw_data/C0701131D19.csv",
  "raw_data/C0701131D20.csv",
  "raw_data/C0701131D21.csv",
  "raw_data/C0701131D22.csv",
  "raw_data/C0701131D23.csv",
  "raw_data/C0701131D24.csv",
  "raw_data/C0701131D25.csv",
  "raw_data/C0701131D26.csv",
  "raw_data/C0701131D27.csv",
  "raw_data/C0701131D28.csv",
  "raw_data/C0701131D29.csv",
  "raw_data/C0701131D30.csv",
  "raw_data/C0701131D31.csv",
  "raw_data/C0701131D32.csv",
  "raw_data/C0701131D33.csv",
  "raw_data/C0701131D34.csv",
  "raw_data/C0701131D35.csv"
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

names(mae)                       # experiments: single-agent + combination
se_combo <- mae[["combination"]]
assayNames(se_combo)
head(rowData(se_combo))          # row metadata = library drug x sotorasib
colData(se_combo)                # column metadata = cell lines

# ==============================================================================
# Step 4: Extract assay data as data.tables
# ==============================================================================

averaged <- convert_mae_assay_to_dt(mae, "Averaged")
metrics  <- convert_mae_assay_to_dt(mae, "Metrics")
scores   <- convert_mae_assay_to_dt(mae, "scores")
excess   <- convert_mae_assay_to_dt(mae, "excess")

# ==============================================================================
# Step 5: Which library compounds shift sotorasib response? (synergy summary)
# ==============================================================================

synergy_summary <- scores[, .(
  mean_Bliss = mean(bliss_score, na.rm = TRUE),
  mean_HSA = mean(hsa_score, na.rm = TRUE)
), by = .(CellLineName, DrugName, DrugName_2)]
print(head(synergy_summary[order(-mean_Bliss)], 20))   # strongest co-treatment effects

# ==============================================================================
# Step 6: Chemical-genomics analysis (drug-class enrichment, GSEA)
# ==============================================================================
# The dataset's primary analysis groups library compounds by mechanism of action
# and tests, via GSEA, which MOAs are sensitized or rescued by sotorasib co-treatment.
# See the rendered report 3-1-chemical_genomics_analysis.html for the full analysis.

message("\nDone! Explore further with assayNames(se_combo) and convert_mae_assay_to_dt()")
