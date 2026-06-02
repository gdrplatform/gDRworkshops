# LargeDrugCombo — Goetz et al., Cancers 2024

Large-scale drug combination screen analyzing synergy between **Belvarafenib x Cobimetinib** and **Vemurafenib x Cobimetinib** across a panel of melanoma and colorectal cancer cell lines.

**Publication:** [Goetz et al., *Cancers* 2024](https://pubmed.ncbi.nlm.nih.gov/39199684/)

## Reports

| Step | Report | Description |
|------|--------|-------------|
| 1 | `1-data_import` | Import raw CSV plate reader files into gDR format |
| 2 | `2-processing_and_QC` | Dose-response processing and quality control |
| 3 | `3-analysis` | Synergy analysis (Bliss, HSA) and visualization |

## Data

| Directory | Contents |
|-----------|----------|
| `raw_data/` | Raw plate reader CSVs and template/manifest files |
| `data_annotation/` | Cell line and drug annotation CSVs |
| `gDR_data/` | Processed MultiAssayExperiment objects (`.qs2`) |
| `plots/` | Generated SVG figures |
| `tables/` | Result tables (`.xlsx`) |
