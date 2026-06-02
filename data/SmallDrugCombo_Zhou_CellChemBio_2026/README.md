# SmallDrugCombo — Zhou et al., Cell Chemical Biology 2026

Drug combination screen analyzing synergy between **Inavolisib x Giredestrant** and **Everolimus x Giredestrant** across breast cancer cell lines (CAMA-1, EFM-19, MCF-7, T-47D).

**Publication:** [Zhou et al., *Cell Chemical Biology* 2026](https://www.cell.com/cell-chemical-biology/fulltext/S2451-9456(26)00143-1)

## Reports

| Step | Report | Description |
|------|--------|-------------|
| 1 | `1-data_import` | Import raw Excel files into gDR format |
| 2 | `2-processing_and_QC` | Dose-response processing and quality control |
| 3 | `3-analysis` | Synergy analysis (Bliss, HSA) and visualization |

## Data

| Directory | Contents |
|-----------|----------|
| `raw_data/` | Raw treatment and manifest Excel files |
| `data_annotation/` | Cell line and drug annotation CSVs |
| `gDR_data/` | Processed MultiAssayExperiment objects (`.qs2`) |
| `plots/` | Generated SVG figures |
| `tables/` | Result tables (`.xlsx`) |
