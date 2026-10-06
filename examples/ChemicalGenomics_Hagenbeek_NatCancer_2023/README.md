# ChemicalGenomics — Hagenbeek et al., Nature Cancer 2023

Anchored combination screen: a ~747-compound library tested against a fixed dose
of the KRAS-G12C inhibitor sotorasib in two NSCLC cell lines. The design probes
which library compounds shift sotorasib sensitivity (chemical-genomics readout).

**Publication:** [Hagenbeek et al., *Nature Cancer* 2023](https://www.nature.com/articles/s43018-023-00577-0)

## At a glance

| | |
|---|---|
| **Cell lines** | 2 (NCI-H23, NCI-H358) |
| **Tissue** | Lung (NSCLC) |
| **Design** | Anchored combination — library (~747 compounds) × fixed sotorasib |
| **Anchor** | Sotorasib (KRAS G12C) |
| **Analysis type** | Chemical genomics + drug combination |
| **Metrics** | GR, RV, Bliss excess, HSA excess, isobolograms |

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
| 3.1 | [chemical_genomics_analysis](3-1-chemical_genomics_analysis.html) | Cotreatment-vs-single-agent chemical-genomics analysis |

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
