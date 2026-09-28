# Timecourse — HMS LINCS MCF10A common project, 2016

Live-imaging drug response in non-tumorigenic mammary epithelial cells. Six 384-well plates of
MCF10A-H2B-mCherry imaged in an Incucyte every four hours for five days under eight drugs.

This is the time-course example: the readout is a cell count per well over time rather than a
single endpoint, so the pipeline runs in time-course mode and the analysis produces growth
rates instead of viability.

**Source:** [HMS LINCS Center](https://lincs.hms.harvard.edu/), MCF10A common project,
experiment `MN20160421`. Raw exports, plate map and plate table are included here exactly as
published.

## At a glance

| | |
|---|---|
| **Cell line** | 1 (MCF10A-H2B-mCherry) |
| **Tissue** | Breast, non-tumorigenic |
| **Plates** | 6 × 384-well, 308 wells used per plate |
| **Drugs** | 8, at 7-9 concentrations each |
| **Timepoints** | 31-32 per plate, every ~4 h over 0-124 h |
| **Analysis type** | Time-course (growth rate) |
| **Metrics** | Normalized growth rate, xc50, Hill coefficient, AOC |

## Drugs

| Drug | HMS LINCS id | Target (MOA) |
|------|--------------|--------------|
| Alpelisib | HMSL10233 | PIK3CA |
| Dasatinib | HMSL10020 | SRC/ABL |
| Etoposide | HMSL10250 | TOP2A |
| Neratinib | HMSL10018 | ERBB2/EGFR |
| Paclitaxel | HMSL10102 | Tubulin |
| Palbociclib | HMSL10071 | CDK4/6 |
| Trametinib | HMSL10142 | MEK1/2 |
| Vorinostat | HMSL10282 | HDAC |

## Reports

| Step | Report | Description |
|------|--------|-------------|
| 1 | [data_import](1-data_import.Rmd) | Prepare the Incucyte exports, build manifest and template from the published plate map, import into gDR |
| 2 | [processing_and_QC](2-processing_and_QC.Rmd) | Anchor the timepoints on treatment start, normalize, inspect trajectories |
| 3 | [analysis](3-analysis.Rmd) | Growth rates per time window, dose-response fits, cross-check against the published metrics |

## Quick start

1. Set your working directory to this folder in RStudio
2. Open any `.Rmd` file and follow along interactively, or render all three:

```r
for (f in c("1-data_import.Rmd", "2-processing_and_QC.Rmd", "3-analysis.Rmd")) {
  rmarkdown::render(f)
}
```

The whole example runs in a few minutes — unlike the other examples here it is small
enough that no reduced subset is needed.

## Data

| Directory | Contents |
|-----------|----------|
| `raw_data/` | Incucyte exports, published plate map, plate table and GR metrics — all unedited |
| `data_annotation/` | Cell line and drug annotation CSVs |
| `gDR_data/` | Processed objects (`.qs2`) |
| `plots/` | Generated SVG figures |
| `tables/` | Result tables (`.xlsx`) |

## Two things worth knowing before you adapt this

**The instrument clock is not the experiment clock.** `Elapsed` in an Incucyte export counts
from the start of imaging, which here is plating. Treatment begins 24 h later on three plates
and 48 h later on the other three. Report 2 shifts each plate onto its own treatment start;
skipping that step silently mixes pre-treatment growth into the response.

**Time windows are a choice, not a default.** `fit_SE.timecourse()` requires `periods` and
`normalization_map` explicitly. They encode a hypothesis about when a drug acts, and they
change the answer more than any other argument in the pipeline.
