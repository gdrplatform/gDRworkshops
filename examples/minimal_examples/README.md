# Minimal Working Examples

Self-contained R scripts that demonstrate the full gDR pipeline for each dataset — from raw data import through processing to visualization.

## Scripts

| Script | Dataset | Type |
|--------|---------|------|
| `SmallDrugCombo_run_analysis.R` | SmallDrugCombo (Zhou et al.) | Drug combination |
| `LargeDrugCombo_run_analysis.R` | LargeDrugCombo (Goetz et al.) | Drug combination |
| `PRISMBroadScreen_run_analysis.R` | PRISMBroadScreen (Hagenbeek et al.) | Single-agent |

## How to use

1. Open the repository in RStudio (or set your working directory to the repo root)
2. Run any script line by line to walk through:
   - Data import and annotation
   - `runDrugResponseProcessingPipeline()`
   - Exploring the `MultiAssayExperiment` structure
   - Extracting assay data as `data.table`
   - Generating visualizations
