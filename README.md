# gDRworkshops

Workshop materials for the gDR platform — dose-response analysis in R.

## Datasets

| Dataset | Reference | Type |
|---------|-----------|------|
| SmallDrugCombo | Zhou et al., Cell Chem Bio 2026 | Combination (small) |
| LargeDrugCombo | Goetz et al., Cancers 2024 | Combination (large) |
| PRISMBroadScreen | Hagenbeek et al., Nat Comm 2026 | Single-agent (broad screen) |

## Structure

Each dataset directory contains:
- `*.Rmd` — R Markdown source files (import, processing/QC, analysis)
- `*.html` — rendered reports
- `data_annotation/` — cell line and drug annotations
- `gDR_data/` — processed gDR objects
- `plots/` — generated figures
