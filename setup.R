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
  "gDR", "gDRcore", "gDRutils",
  "MultiAssayExperiment", "SummarizedExperiment",
  "depmap", "BiocStyle"
)

cran_pkgs <- c(
  "data.table", "ggplot2", "purrr", "qs2",
  "summarytools", "writexl"
)

options(Ncpus = 1)
Sys.setenv(R_COMPILE_PKGS = "0")  # disable byte-compilation to avoid OOM on low-RAM systems

# gDRimport first, from branch with CoreGx/PharmacoGx as optional (Suggests)
# to avoid >1GB compilation in memory-constrained environments
remotes::install_github("gdrplatform/gDRimport@fix/coregx-optional", upgrade = "never")

BiocManager::install(bioc_pkgs, ask = FALSE, update = FALSE)
install.packages(setdiff(cran_pkgs, rownames(installed.packages())), repos = "https://cloud.r-project.org")

# gDRplots is not yet on Bioconductor — install from GitHub
remotes::install_github("gdrplatform/gDRplots", upgrade = "never")

# --- 2. Download CCLE/DepMap data (subsetted to relevant cell lines) ---

library(depmap)
library(data.table)

workshop_dir <- normalizePath(dirname(sys.frame(1)$ofile))

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

# Free memory before loading large omics matrices
rm(prism_full_data, prism_sub_data, model_full, model_for_full, model_for_sub)
gc()
message("Memory freed. Starting omics file subsetting...")

# Subset omics files by ModelID and save to full example only.
# Filter rows at the OS level (grep) to avoid loading full matrices into R RAM.
ids_file <- tempfile()
writeLines(full_model_ids, ids_file)

omics_files <- setdiff(required_files, "Model.csv")
for (fname in omics_files) {
  message("Filtering: ", fname, " ...")
  src <- cached_paths[[fname]]
  cmd <- sprintf('bash -c "{ head -1 %s; grep -F -f %s %s; }"',
                 shQuote(src), shQuote(ids_file), shQuote(src))
  dt <- fread(cmd = cmd, nThread = 1)
  fwrite(dt, file.path(prism_meta, fname))
  message("Saved ", fname, " (", nrow(dt), " cell lines)")
  rm(dt)
  gc()
}
unlink(ids_file)

message("\nSetup complete! Please restart your R session before opening the workshop files.")
message("In RStudio / Posit Cloud: Session > Restart R  (Ctrl+Shift+F10 / Cmd+Shift+F10)")
