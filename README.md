<p align="center">
  <img src="gdr_logo.png" alt="gDR logo" width="300">
</p>

<h1 align="center">gDR Workshops</h1>

<p align="center">
  Hands-on workshop materials for the <a href="https://github.com/gdrplatform">gDR platform</a> — dose-response analysis in R.
</p>

---

## Overview

This repository contains reproducible analyses demonstrating the gDR workflow on real-world published datasets. Each example walks through the full pipeline: data import, processing & QC, and downstream analysis.

## Getting started

1. Clone this repository:
   ```bash
   git clone https://github.com/gdrplatform/gDRworkshops.git
   ```

2. Install dependencies and download external data:
   ```r
   source("setup.R")
   ```

3. Open any `.html` report in a browser to view the rendered analysis, or open the `.Rmd` files in RStudio to follow along interactively.

## Datasets

| Dataset | Publication | Type |
|---------|-------------|------|
| **SmallDrugCombo** | [Zhou et al., *Cell Chem Bio* 2026](https://www.cell.com/cell-chemical-biology/fulltext/S2451-9456(26)00143-1) | Drug combination (small) |
| **LargeDrugCombo** | [Goetz et al., *Cancers* 2024](https://pubmed.ncbi.nlm.nih.gov/39199684/) | Drug combination (large) |
| **PRISMBroadScreen** | Hagenbeek et al., *Nat Commun* 2026 (accepted; link TBD) | Single-agent broad screen |

## Prerequisites

- **R** (≥ 4.4) with **Bioconductor** (≥ 3.23)
- **macOS only** — install `cmake` before running `setup.R`:
  ```bash
  brew install cmake
  ```
- **Windows only** — verify that Rtools is installed:
  ```r
  source("check_rtools.R")
  ```
- **Bioconductor** packages:
  ```r
  BiocManager::install(c("gDR", "gDRcore", "gDRimport", "gDRutils",
                          "MultiAssayExperiment", "SummarizedExperiment",
                          "depmap", "BiocStyle"))
  ```
- **GitHub** packages (not yet on Bioconductor):
  ```r
  remotes::install_github("gdrplatform/gDRplots")
  ```
- **CRAN** packages:
  ```r
  install.packages(c("data.table", "ggplot2", "purrr", "qs2",
                      "summarytools", "writexl", "remotes"))
  ```

Alternatively, run `setup.R` from the repository root to install all dependencies and download required external data in one step.

## Having trouble with local installation?

If you run into issues installing packages locally, you can follow the workshop entirely in the cloud using [Posit Cloud](https://posit.cloud/):

1. Go to [posit.cloud](https://posit.cloud/) and create a free account.
2. Click **New Project → New RStudio Project** (the default blank project uses R 4.6 with Bioconductor 3.23 — do not use the R Markdown template as it defaults to an older R version).
3. In the RStudio terminal, clone this repository:
   ```bash
   git clone https://github.com/gdrplatform/gDRworkshops.git
   ```
4. In the R console, set the working directory and run setup:
   ```r
   setwd("gDRworkshops")
   source("setup.R")
   ```

Posit Cloud runs on Linux and provides pre-compiled binaries for most packages, so installation is faster and less error-prone than on a local machine.

## Repository structure

```
examples/
├── SmallDrugCombo_Zhou_CellChemBio_2026/
├── LargeDrugCombo_Goetz_Cancers_2024/
├── PRISMBroadScreen_Hagenbeek_NatComm_2026/
└── subsets/                          # Reduced datasets for quick workshop runs
    ├── SmallDrugCombo/
    ├── LargeDrugCombo/
    └── PRISMBroadScreen/
```

Each example directory contains its own `README.md` with a detailed description. The general structure is:

| File/Directory | Description |
|----------------|-------------|
| `1-data_import.Rmd/.html` | Data import from raw files |
| `2-processing_and_QC.Rmd/.html` | Processing and quality control |
| `3-analysis.Rmd/.html` | Analysis and visualization |
| `data_annotation/` | Cell line and drug annotations |
| `gDR_data/` | Processed gDR objects (`.qs2`) |
| `raw_data/` | Raw input data |
| `plots/` | Generated figures |
| `tables/` | Result tables |

## Related packages

- [gDR](https://github.com/gdrplatform/gDR) — meta-package installing the full gDR suite
- [gDRcore](https://github.com/gdrplatform/gDRcore) — core processing engine
- [gDRutils](https://github.com/gdrplatform/gDRutils) — utility functions
- [gDRimport](https://github.com/gdrplatform/gDRimport) — data import
- [gDRplots](https://github.com/gdrplatform/gDRplots) — static visualizations


## Contact

For questions, bug reports, or feature requests, please [open an issue](https://github.com/gdrplatform/gDRworkshops/issues) on GitHub.

## License

This work is licensed under the [Artistic License 2.0](https://opensource.org/licenses/Artistic-2.0).
