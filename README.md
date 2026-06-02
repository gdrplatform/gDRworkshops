# gDRworkshops

Workshop materials for the [gDR platform](https://github.com/gdrplatform) — dose-response analysis in R.

## Datasets

| Directory | Reference | Type |
|-----------|-----------|------|
| `SmallDrugCombo_Zhou_CellChemBio_2026` | [Zhou et al., *Cell Chem Bio* 2026](https://www.cell.com/cell-chemical-biology/fulltext/S2451-9456(26)00143-1) | Drug combination (small) |
| `LargeDrugCombo_Goetz_Cancers_2024` | [Goetz et al., *Cancers* 2024](https://pubmed.ncbi.nlm.nih.gov/39199684/) | Drug combination (large) |
| `PRISMBroadScreen_Hagenbeek_NatComm_2026` | Hagenbeek et al., *Nat Commun* 2026 (accepted) | Single-agent broad screen |

## Structure

Each dataset directory under `data/` contains:

- `1-data_import.Rmd/.html` — data import
- `2-processing_and_QC.Rmd/.html` — processing and quality control
- `3-analysis.Rmd/.html` — analysis and visualization
- `data_annotation/` — cell line and drug annotation files
- `gDR_data/` — processed gDR objects (`.qs2`)
- `raw_data/` — raw input data
- `plots/` — generated figures
- `tables/` — result tables
