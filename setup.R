# gDR Workshops — Setup Script
# Run this script once before the workshop to install all dependencies
# and download required external data.
#
# NOTE: macOS users must install cmake first (required by the nloptr package):
#   brew install cmake
#
# If you have trouble installing packages locally, use Posit Cloud instead:
#   https://posit.cloud/ — create a blank RStudio project (R 4.6), clone this
#   repo, then: setwd("gDRworkshops"); source("setup.R")

# --- 1. Install packages ---

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes")

bioc_pkgs <- c(
  "gDR", "gDRcore", "gDRimport", "gDRutils",
  "MultiAssayExperiment", "SummarizedExperiment",
  "depmap", "BiocStyle"
)

cran_pkgs <- c(
  "data.table", "ggplot2", "purrr", "qs2",
  "summarytools", "writexl"
)

options(Ncpus = 1)  # limit parallelism to reduce peak memory usage
BiocManager::install(bioc_pkgs, ask = FALSE, update = FALSE)
install.packages(setdiff(cran_pkgs, rownames(installed.packages())), repos = "https://cloud.r-project.org")

# gDRplots is not yet on Bioconductor — install from GitHub
remotes::install_github("gdrplatform/gDRplots", upgrade = "never")

# --- 2. Download CCLE/DepMap data (subsetted to relevant cell lines) ---

library(depmap)
library(data.table)

workshop_dir <- getwd()

# Full PRISM example
prism_raw <- file.path(workshop_dir, "examples",
  "PRISMBroadScreen_Hagenbeek_NatComm_2026", "raw_data")
prism_meta <- file.path(prism_raw, "meta")
dir.create(prism_meta, showWarnings = FALSE, recursive = TRUE)

# Subset PRISM example
prism_subset_raw <- file.path(workshop_dir, "examples",
  "subsets", "PRISMBroadScreen", "raw_data")

# Get ccle_names from both PRISM datasets
prism_full_data <- fread(file.path(prism_raw, "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"))
full_ccle_names <- unique(prism_full_data$ccle_name)

prism_sub_data <- fread(file.path(prism_subset_raw, "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"))
sub_ccle_names <- unique(prism_sub_data$ccle_name)

required_files <- c(
  "Model.csv",
  "OmicsCNGene.csv",
  "OmicsExpressionProteinCodingGenesTPMLogp1.csv",
  "OmicsSomaticMutationsMatrixDamaging.csv",
  "OmicsSomaticMutationsMatrixHotspot.csv"
)

available <- dmfiles()
latest_dataset_id <- max(available$dataset_id)
to_download <- available[available$dataset_id == latest_dataset_id & available$name %in% required_files, ]

if (nrow(to_download) < length(required_files)) {
  missing <- setdiff(required_files, to_download$name)
  warning("Files not found in depmap: ", paste(missing, collapse = ", "))
}

cached_paths <- dmget(to_download)
names(cached_paths) <- to_download$name

# Process Model.csv first to get ModelID <-> CCLEName mapping
model_full <- fread(cached_paths[["Model.csv"]])

model_for_full <- model_full[CCLEName %in% full_ccle_names]
full_model_ids <- model_for_full$ModelID
fwrite(model_for_full, file.path(prism_raw, "Model.csv"))

model_for_sub <- model_full[CCLEName %in% sub_ccle_names]
fwrite(model_for_sub, file.path(prism_subset_raw, "Model.csv"))

message("Saved Model.csv (full: ", nrow(model_for_full),
        ", subset: ", nrow(model_for_sub), " cell lines)")

# Subset omics files by ModelID and save to full example only
omics_files <- setdiff(required_files, "Model.csv")
for (fname in omics_files) {
  dt <- fread(cached_paths[[fname]])
  id_col <- names(dt)[1]
  dt <- dt[get(id_col) %in% full_model_ids]
  fwrite(dt, file.path(prism_meta, fname))
  message("Saved ", fname, " (", nrow(dt), " cell lines)")
}

message("\nSetup complete! You're ready for the workshop.")
