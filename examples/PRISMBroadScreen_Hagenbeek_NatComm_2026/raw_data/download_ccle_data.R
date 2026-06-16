# Download CCLE/DepMap public data files
# These files are not redistributed in this repository.
# Run this script to fetch them from the public DepMap portal via the depmap package.
# Files are subsetted to only cell lines present in this example.

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("depmap", quietly = TRUE))
  BiocManager::install("depmap")
if (!requireNamespace("data.table", quietly = TRUE))
  install.packages("data.table")

library(depmap)
library(data.table)

script_dir <- dirname(sys.frame(1)$ofile)
dest_dir <- file.path(script_dir, "meta")
dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

# Get ccle_names from the PRISM data
prism_data <- fread(file.path(script_dir, "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"))
ccle_names <- unique(prism_data$ccle_name)

required_files <- c(
  "Model.csv",
  "OmicsExpressionProteinCodingGenesTPMLogp1.csv"
  # Additional omics files (uncomment to download):
  # "OmicsCNGene.csv",
  # "OmicsSomaticMutationsMatrixDamaging.csv",
  # "OmicsSomaticMutationsMatrixHotspot.csv"
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

# First process Model.csv to get the ModelID <-> CCLEName mapping
model_full <- fread(cached_paths[["Model.csv"]])
model_sub <- model_full[CCLEName %in% ccle_names]
model_ids <- model_sub$ModelID
fwrite(model_sub, file.path(script_dir, "Model.csv"))
message("Saved Model.csv (", nrow(model_sub), " cell lines)")

# Subset omics files by ModelID (first column)
omics_files <- setdiff(required_files, "Model.csv")
for (fname in omics_files) {
  dt <- fread(cached_paths[[fname]])
  id_col <- names(dt)[1]
  dt <- dt[get(id_col) %in% model_ids]
  fwrite(dt, file.path(dest_dir, fname))
  message("Saved ", fname, " (", nrow(dt), " cell lines)")
}
