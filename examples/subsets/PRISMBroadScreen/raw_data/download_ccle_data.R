# Download CCLE/DepMap public data files
# These files are not redistributed in this repository.
# Run this script to fetch them from the public DepMap portal via the depmap package.
# Files are subsetted to only cell lines present in this subset.

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("depmap", quietly = TRUE))
  BiocManager::install("depmap")
if (!requireNamespace("data.table", quietly = TRUE))
  install.packages("data.table")

library(depmap)
library(data.table)

script_dir <- dirname(sys.frame(1)$ofile)

# Get ccle_names from the subset PRISM data
prism_data <- fread(file.path(script_dir, "CPS008_DMC_GENENTECH_LEVEL5_LFC_COMBAT_GDC8025"))
ccle_names <- unique(prism_data$ccle_name)

required_files <- c("Model.csv")

available <- dmfiles()
to_download <- available[available$name %in% required_files, ]

cached_paths <- dmget(to_download)

model_full <- fread(cached_paths[1])
model_sub <- model_full[CCLEName %in% ccle_names]
fwrite(model_sub, file.path(script_dir, "Model.csv"))
message("Saved Model.csv (", nrow(model_sub), " cell lines)")
