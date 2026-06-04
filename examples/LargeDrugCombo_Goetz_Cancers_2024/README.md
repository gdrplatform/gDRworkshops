# LargeDrugCombo — Goetz et al., Cancers 2024

Large-scale drug combination screen evaluating RAF/MEK inhibitor synergy in skin cancer cell lines.

**Publication:** [Goetz et al., *Cancers* 2024](https://pubmed.ncbi.nlm.nih.gov/39199684/)

## At a glance

| | |
|---|---|
| **Cell lines** | 43 (melanoma, squamous cell carcinoma) |
| **Tissue** | Skin |
| **Combinations** | Belvarafenib × Cobimetinib, Vemurafenib × Cobimetinib |
| **Analysis type** | Drug combination (synergy) |
| **Metrics** | GR, RV, Bliss excess, HSA excess |

## Drugs

| Drug | Target (MOA) |
|------|-------------|
| Belvarafenib | BRAF, RAF1, ARAF |
| Vemurafenib | BRAF |
| Cobimetinib | MAP2K1, MAP2K2 |

## Reports

| Step | Report | Description |
|------|--------|-------------|
| 1 | [data_import](1-data_import.html) | Import raw CSV plate reader files into gDR format |
| 2 | [processing_and_QC](2-processing_and_QC.html) | Dose-response processing and quality control |
| 3 | [analysis](3-analysis.html) | Synergy analysis (Bliss, HSA) and visualization |

## Quick start

1. Open `LargeDrugCombo.Rproj` in RStudio
2. Open any `.Rmd` file and follow along interactively, or view the pre-rendered `.html` reports in a browser

## Data

| Directory | Contents |
|-----------|----------|
| `raw_data/` | Raw plate reader CSVs (43 plates) and template/manifest files |
| `data_annotation/` | Cell line and drug annotation CSVs |
| `gDR_data/` | Processed MultiAssayExperiment objects (`.qs2`) |
| `plots/` | Generated SVG figures |
| `tables/` | Result tables (`.xlsx`) |
