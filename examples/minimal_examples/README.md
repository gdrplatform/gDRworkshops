# Minimal Working Examples

Self-contained R scripts that demonstrate the full gDR pipeline for each dataset — from raw data import through processing to visualization.

## Scripts

| Script | Dataset | Type |
|--------|---------|------|
| `SmallDrugCombo_run_analysis.R` | SmallDrugCombo (Zhou et al.) | Drug combination |
| `LargeDrugCombo_run_analysis.R` | LargeDrugCombo (Goetz et al.) | Drug combination |
| `PRISMBroadScreen_run_analysis.R` | PRISMBroadScreen (Hagenbeek et al.) | Single-agent |
| `ChemicalGenomics_run_analysis.R` | ChemicalGenomics (Hagenbeek et al.) | Anchored combination |
| `Timecourse_run_analysis.R` | Timecourse (HMS LINCS MCF10A) | Time-course (live imaging) |

## How to use

1. Open the repository in RStudio (or set your working directory to the repo root)
2. Run any script line by line to walk through:
   - Data import and annotation
   - `runDrugResponseProcessingPipeline()`
   - Exploring the `MultiAssayExperiment` structure
   - Extracting assay data as `data.table`
   - Generating visualizations

`Timecourse_run_analysis.R` differs in one way: the time-course route goes through
`normalize_SE(data_type = "time-course")` and `fit_SE.timecourse()` rather than
`runDrugResponseProcessingPipeline()`, and it needs `periods` and `normalization_map`, which
have no defaults.
