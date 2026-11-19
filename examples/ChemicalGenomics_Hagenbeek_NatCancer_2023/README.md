# ChemicalGenomics — Hagenbeek et al., Nature Cancer 2023

Anchored combination screen: a ~747-compound library tested alone and with a fixed
dose of the KRAS-G12C inhibitor sotorasib, in two NSCLC cell lines and their
sotorasib-resistant derivatives. The design probes which library compounds shift
sotorasib sensitivity (chemical-genomics readout).

**Publication:** [Hagenbeek et al., *Nature Cancer* 2023](https://www.nature.com/articles/s43018-023-00577-0)

## At a glance

| | |
|---|---|
| **Cell lines** | 4: NCI-H23, NCI-H358 and their sotorasib-resistant derivatives (NCI-H23.AMG-510resistance, NCI-H358.AMG-510resistance) |
| **Tissue** | Lung (NSCLC) |
| **Design** | Anchored combination — library (~747 compounds) alone and × fixed sotorasib; 8 arms × 35 dosing templates = 280 plates |
| **Sotorasib dose** | 30 nM for the parental lines, 900 nM for the resistant lines |
| **Anchor** | Sotorasib (KRAS G12C) |
| **Analysis type** | Chemical genomics + drug combination |
| **Metrics** | Relative viability (RV), Bliss excess, HSA excess. GR is left out of this example: it needs the doubling time of each cell line, which is not known for the resistant lines |

## Anchor drug

| Drug | Target (MOA) |
|------|-------------|
| Sotorasib | KRAS |

The library includes published Genentech tool compounds such as GNE-7883 (pan-TEAD).

## Reports

| Step | Report | Description |
|------|--------|-------------|
| 1 | [data_import](1-data_import.html) | Import raw Excel/CSV files into gDR format |
| 2 | [processing_and_QC](2-processing_and_QC.html) | Dose-response processing and quality control |
| 3 | [analysis](3-analysis.html) | Single-agent and combination analysis (Bliss, HSA) |
| 3.1 | [chemical_genomics_analysis](3-1-chemical_genomics_analysis.html) | Co-treatment vs single agent per cell line, and resistant vs parental lines (Fig. 4d of the paper); needs gDRplots >= 0.99.17 |

## Quick start

1. Set your working directory to this folder in RStudio
2. Open any `.Rmd` file and follow along interactively, or view the pre-rendered `.html` reports in a browser

## Data

| Directory | Contents |
|-----------|----------|
| `raw_data/` | Raw treatment templates, manifest, and plate readout files |
| `data_annotation/` | Cell line and drug annotation CSVs |
| `gDR_data/` | Processed MultiAssayExperiment objects (`.qs2`) |
| `plots/` | Generated figures |
| `tables/` | Result tables (`.xlsx`) |
