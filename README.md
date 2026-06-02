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

## Datasets

| Dataset | Publication | Type |
|---------|-------------|------|
| **SmallDrugCombo** | [Zhou et al., *Cell Chem Bio* 2026](https://www.cell.com/cell-chemical-biology/fulltext/S2451-9456(26)00143-1) | Drug combination (small) |
| **LargeDrugCombo** | [Goetz et al., *Cancers* 2024](https://pubmed.ncbi.nlm.nih.gov/39199684/) | Drug combination (large) |
| **PRISMBroadScreen** | Hagenbeek et al., *Nat Commun* 2026 (accepted) | Single-agent broad screen |

## Prerequisites

- **R** (≥ 4.4)
- **Bioconductor** packages:
  ```r
  BiocManager::install(c("gDR", "gDRcore", "gDRimport", "gDRutils", "gDRplots",
                          "MultiAssayExperiment", "SummarizedExperiment"))
  ```
- **CRAN** packages:
  ```r
  install.packages(c("data.table", "ggplot2", "purrr", "qs2",
                      "summarytools", "writexl", "BiocStyle"))
  ```

## Repository structure

```
data/
├── SmallDrugCombo_Zhou_CellChemBio_2026/
├── LargeDrugCombo_Goetz_Cancers_2024/
└── PRISMBroadScreen_Hagenbeek_NatComm_2026/
```

Each dataset directory contains:

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

## Getting started

1. Clone this repository:
   ```bash
   git clone https://github.com/gdrplatform/gDRworkshops.git
   ```

2. Open any `.html` report in a browser to view the rendered analysis, or open the `.Rmd` files in RStudio to follow along interactively.

## Related packages

- [gDRcore](https://github.com/gdrplatform/gDRcore) — core processing engine
- [gDRutils](https://github.com/gdrplatform/gDRutils) — utility functions
- [gDRviz](https://github.com/gdrplatform/gDRviz) — visualization
- [gDRimport](https://github.com/gdrplatform/gDRimport) — data import

## Contact

For questions or support, reach out to the gDR team at **gdr-support-d@gene.com**.

## License

This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
