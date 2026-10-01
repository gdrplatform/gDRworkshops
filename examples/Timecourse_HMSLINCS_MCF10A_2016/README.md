# Timecourse — HMS LINCS MCF10A common project, 2016

Live-imaging drug response in non-tumorigenic mammary epithelial cells. Six 384-well plates of
MCF10A-H2B-mCherry imaged in an Incucyte every four hours for five days under eight drugs.

This is the time-course example: the readout is a cell count per well over time rather than a
single endpoint, so it runs through gDR's **Incucyte report** — the same templates the platform
ships for live-imaging experiments. Unlike the other examples here, this one writes no reports of
its own; it supplies the data, the plate map and an analysis config, and calls `gDR::run_report()`.

**Source:** [HMS LINCS Center](https://lincs.hms.harvard.edu/), MCF10A common project,
experiment `MN20160421`. Raw exports, plate map and plate table are included exactly as published.

## At a glance

| | |
|---|---|
| **Cell line** | 1 (MCF10A-H2B-mCherry) |
| **Tissue** | Breast, non-tumorigenic |
| **Plates** | 6 × 384-well, 308 wells used per plate |
| **Drugs** | 8, at 7–9 concentrations each |
| **Timepoints** | every ~4 h, 0–100 h after treatment |
| **Analysis type** | Time-course (growth rate per phase) |
| **Output** | one multi-page PDF per cell line, a page per treatment comparison |

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

## Quick start

```r
setwd("examples/Timecourse_HMSLINCS_MCF10A_2016")
source("render_report.R")
```

That derives the gDR inputs and then calls `gDR::run_report()`, which writes everything it
produces into `report/v1/`.

**One such run is committed, whole, as [`report/v1/`](report/v1).** You do not have to run
anything to read the example, and nothing in that directory was placed there by hand — it is
what `run_report()` leaves behind:

| In `report/v1/` | What it is |
|---|---|
| [`3-analysis.html`](report/v1/3-analysis.html) and the two steps before it | the rendered reports |
| `1-data_import.Rmd`, `2-processing_and_QC.Rmd`, `3-analysis.Rmd` | the templates the run used, copied in by `run_report()` — gDR's own, not maintained here |
| [`plots/cell_count_curves_20160421_MCF10A.pdf`](report/v1/plots/cell_count_curves_20160421_MCF10A.pdf) | the growth curves, one page per treatment comparison |
| `tables/grow_rates.csv` | the growth rates themselves, long and wide |
| `gDR_data/*.qs2` | the imported table and the MAE — step 2 writes them, step 3 reads them |
| `raw_data/` | the inputs as staged for the run, plus the draft config step 1 generates |
| `logs/` | the run log |

Because the templates come from the installed gDR, this directory is also the answer to "what
does the Incucyte report look like" — there is no copy of it in this repository to drift.

## Files

| File | Contents |
|------|----------|
| `raw_data/` | Incucyte exports, published plate map and plate table — all unedited |
| `raw_data/time_course_plot_params.yml` | the analysis config: phases, normalization, treatment comparisons |
| `prepare_inputs.R` | derives the gDR manifest and template from the published plate table, and rebases the clock |
| `render_report.R` | calls `gDR::run_report()` with the shipped Incucyte templates |
| `report/v1/` | one complete run, committed — see above |

`prepared/` is generated and git-ignored, as is every run after the first: a local re-run
lands in `report/v2/` and stays out of the repository.

## The config is the part you edit

`time_course_plot_params.yml` is where an analysis is defined. It sets the phases
(`early_period`, optional `mid_period`, `late_period`), how each phase is normalized, and
`treatment_comparisons` — a list of treatment sets, one page of the output PDF each.

Treatment labels must match the `treatment` column that `add_treatment_column()` builds:
`"<DrugName> <concentration>uM"`, concentration rounded to four decimals, combination arms
joined with `" + "`. This dataset is single-agent only, so the two comparisons here group the
eight drugs by mechanism — growth signalling, then cell cycle and DNA — at one dose each.

The dose shown per drug is the tested concentration whose early-window growth rate comes closest
to half the untreated rate; where a drug never halves growth over the range tested, the top
concentration is used instead.

## Two things worth knowing before you adapt this

**The instrument clock is not the experiment clock.** `Elapsed` in an Incucyte export counts from
the start of imaging, which here is plating. Treatment begins 24 h later on three plates and 48 h
later on the other three, per the `T0date` column of the plate table. `prepare_inputs.R` rebases
each plate onto the first image after dosing; skipping that step mixes pre-treatment growth into
the response, and the two plate groups contribute different amounts of it.

**The `treatment` marker in the report is drawn at a fixed 10 h.** It is not read from the config,
so on this dataset — where the clock has been rebased and treatment is at 0 — the labelled line
sits in the wrong place. The curves and the phase windows are unaffected.
