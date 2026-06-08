# Subsets — Quick Workshop Data

Reduced datasets for running the gDR pipeline locally during workshops. Each subset contains the same raw data structure as the full examples but with fewer cell lines, enabling fast execution (~2-5 minutes vs 30+ minutes for full data).

## Datasets

| Subset | Cell lines | Source |
|--------|-----------|--------|
| **PRISMBroadScreen** | 15 (diverse tissues) | 774 in full dataset |
| **LargeDrugCombo** | 10 (melanoma + SCC) | 43 in full dataset |

SmallDrugCombo (4 cell lines) is already small enough — use the full example directly.

## How to use

1. For **PRISMBroadScreen**: run `PRISMBroadScreen/run_analysis.R` directly
2. For **LargeDrugCombo**: first run `create_subsets.R` to generate subset data from the full example, then run `LargeDrugCombo/run_analysis.R`

## Cell lines selected

### PRISMBroadScreen (15 lines, 12 tissues)
MCF7 (Breast), A549 (Lung), NCI-H460 (Lung), A375 (Skin), HepG2 (Liver), HCT116 (Bowel), SW480 (Bowel), SKOV3 (Ovary), U251MG (CNS), U2OS (Bone), Jurkat (Lymphoid), K562 (Myeloid), MIA PaCa-2 (Pancreas), A253 (Head & Neck)

### LargeDrugCombo (10 lines)
A-375, A2058, SK-MEL-28 (BRAF-mutant melanoma), COLO 829, COLO 800 (melanoma), HT-144, WM-266-4 (metastatic melanoma), MEL-JUSO (NRAS melanoma), A-431, HSC-1 (squamous cell carcinoma)
