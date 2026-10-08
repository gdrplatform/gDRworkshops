# Subsets — Quick Workshop Data

Reduced datasets for running the gDR pipeline locally during workshops. Each subset mirrors the full example structure but with less data — fewer cell lines, or fewer compounds — enabling fast processing.

## Datasets

| Subset | Reduced to | Source |
|--------|-----------|--------|
| **SmallDrugCombo** | 4 cell lines (full dataset) | Same as full example |
| **LargeDrugCombo** | 10 cell lines (melanoma + SCC) | 43 in full dataset |
| **PRISMBroadScreen** | 15 cell lines (diverse tissues) | 774 in full dataset |
| **ChemicalGenomics** | 20 library compounds (both cell lines) | 747 compounds in full dataset |

The ChemicalGenomics screen has only two cell lines, so its subset trims the compound library (the heavy dimension) instead: `1-data_import.Rmd` imports the full plates and keeps 20 library compounds before processing.

`Timecourse_HMSLINCS_MCF10A_2016` has no subset on purpose. The subsets exist because the full
examples are 40-235 MB and take 30+ minutes; that example is 8 MB in total, of which 0.35 MB is
data and the rest one committed run of the reports. A reduced copy would add
maintenance without saving anyone time. Run the full one.

## How to use

Each subset directory mirrors the full example structure with `1-data_import.Rmd`, `2-processing_and_QC.Rmd`, and `3-analysis.Rmd` reports, as well as a quick `run_analysis.R` script. For the PRISMBroadScreen subset, run `download_ccle_data.R` first (or `setup.R` from the repo root) to fetch the required Model.csv from DepMap.

## Cell lines selected

### SmallDrugCombo (4 lines — full dataset)
CAMA-1, EFM-19, MCF-7, T-47D (ER+ breast cancer)

### LargeDrugCombo (10 lines)
A-375, A2058, SK-MEL-28 (BRAF-mutant melanoma), COLO 829, COLO 800 (melanoma), HT-144, WM-266-4 (metastatic melanoma), MEL-JUSO (NRAS melanoma), A-431, HSC-1 (squamous cell carcinoma)

### PRISMBroadScreen (14 lines, 12 tissues)
MCF7 (Breast), A549 (Lung), NCI-H460 (Lung), A375 (Skin), HepG2 (Liver), HCT116 (Bowel), SW480 (Bowel), SKOV3 (Ovary), U251MG (CNS), U2OS (Bone), Jurkat (Lymphoid), K562 (Myeloid), MIA PaCa-2 (Pancreas), A253 (Head & Neck)
