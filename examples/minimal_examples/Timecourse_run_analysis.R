# Minimal working example: Timecourse (HMS LINCS MCF10A common project, 2016)
# Live-imaging time course: MCF10A-H2B-mCherry, 8 drugs, cell count every ~4 h for five days
# Run this script from the repository root or set wd below to the dataset path
#
# The full example renders gDR's own Incucyte reports (see
# ../Timecourse_HMSLINCS_MCF10A_2016/render_report.R). This script does the same pipeline by
# hand, so each step is visible: import -> SE -> LogFoldChange -> growth rates per window.

library(gDR)
library(gDRcore)
library(gDRimport)
library(gDRutils)
library(SummarizedExperiment)
library(data.table)
library(ggplot2)

wd <- local({
  d <- tryCatch(dirname(sys.frame(1)$ofile), error = function(e) NULL)
  if (is.null(d)) {
    f <- sub("--file=", "", commandArgs(FALSE)[grep("--file=", commandArgs(FALSE))])
    if (length(f) > 0 && nzchar(f)) d <- dirname(f)
  }
  if (is.null(d) && requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    d <- dirname(rstudioapi::getSourceEditorContext()$path)
  if (is.null(d) || !nzchar(d))
    stop("Cannot determine script directory. Run via source(), Rscript, or Source button.")
  normalizePath(file.path(d, "..", "Timecourse_HMSLINCS_MCF10A_2016"))
})

# ==============================================================================
# Step 1: Derive the gDR inputs from the published release
# ==============================================================================

# The published files are not gDR inputs yet: the exports label plates with `Label:` instead of
# `Barcode`, the plate map is a long table rather than a positional grid, and `Elapsed` counts
# from plating rather than from treatment. prepare_inputs.R handles all three.
prepared <- file.path(wd, "prepared")
if (!dir.exists(prepared)) {
  local({
    old <- setwd(wd)
    on.exit(setwd(old))
    source(file.path(wd, "prepare_inputs.R"), local = TRUE)
  })
}

manifest <- file.path(prepared, "manifest_20160421.xlsx")
treatment <- file.path(prepared, "Template_20160421_308.xlsx")
raw_data <- list.files(prepared, pattern = "total\\.xlsx$", full.names = TRUE)

data_imported <- import_data(manifest, treatment, raw_data, instrument = "Incucyte")
setDT(data_imported)

# One row per well per timepoint - the duration column is what makes this a time course
head(data_imported[, .(Barcode, WellRow, WellColumn, Gnumber, Concentration, Duration, ReadoutValue)])

# ==============================================================================
# Step 2: Build the SummarizedExperiment and normalize
# ==============================================================================

tc_type <- get_supported_experiments("time-course")
se_tc <- create_SE(data_imported, data_type = tc_type)

# Log2 fold change against each well's own time zero
se_tc <- normalize_SE(se_tc, data_type = tc_type)

assayNames(se_tc)   # RawTreated, Controls, LogFoldChange
rowData(se_tc)      # treatments
colData(se_tc)      # plates

# ==============================================================================
# Step 3: Growth rates per time window
# ==============================================================================

# periods and normalization_map have no defaults and change the answer more than anything else
# here. "None" keeps the raw rate; naming a period divides by the DMSO rate of that period.
periods <- list(early = c(0, 24), mid = c(36, 60), late = c(72, 100))
norm_map <- c(early = "early", mid = "mid", late = "late")

# Which timepoints actually fall in each window - a window can hold fewer points than intended
get_period_timepoints(se_tc, periods)

growth_dt <- compute_growth_rates(se_tc, periods = periods, normalization_map = norm_map)
growth_dt <- as.data.table(growth_dt)

head(growth_dt[, .(CellLineName, DrugName, Concentration, period,
                   GrowthRate, rate_0, NormalizedGrowthRate)])

# rate_0 is the control rate the normalization divided by. It is NA where no control was
# available and the ratio is NA where the control was not growing - a non-positive denominator
# inverts the sign of the ratio instead of scaling it.
growth_dt[, .N, by = .(period, usable = !is.na(NormalizedGrowthRate))]

# ==============================================================================
# Step 4: Dose response of the growth rate, per window
# ==============================================================================

se_fit <- fit_SE.timecourse(se_tc, periods = periods, normalization_map = norm_map)
assayNames(se_fit)

# Rows are "<drug>|<cell line>" and columns are the windows, so the fit is per treatment per
# window. normalization_type is NGR - the curve is fitted to the normalized growth rate, not to
# viability, so xc50 is the dose that halves growth in that window.
metrics <- as.data.table(convert_se_assay_to_dt(se_fit, "Metrics"))
head(metrics[, .(treatment = rId, period = cId, normalization_type, xc50, x_inf, r2)])

# ==============================================================================
# Step 5: Plot the trajectories the reports build towards
# ==============================================================================

lfc <- as.data.table(convert_se_assay_to_dt(se_tc, "LogFoldChange"))
lfc <- lfc[!is.na(LogFoldChange)]

# One drug, every concentration: the shape over time is what a time course adds over an endpoint
one_drug <- lfc[DrugName == "Palbociclib"]
ggplot(one_drug, aes(x = Duration, y = LogFoldChange,
                     colour = factor(signif(Concentration, 3)))) +
  stat_summary(fun = mean, geom = "line") +
  labs(title = "Palbociclib - MCF10A", x = "Hours after treatment",
       y = "Log2 fold change", colour = "uM") +
  theme_bw()

# Growth rate against dose, one panel per window
ggplot(growth_dt[DrugName != "vehicle" & !is.na(NormalizedGrowthRate)],
       aes(x = Concentration, y = NormalizedGrowthRate, colour = DrugName)) +
  geom_line() +
  scale_x_log10() +
  facet_wrap(~ period) +
  labs(title = "Normalized growth rate by window", x = "Concentration (uM)") +
  theme_bw()

message("\nDone! The same analysis as gDR's Incucyte reports - see ",
        "../Timecourse_HMSLINCS_MCF10A_2016/render_report.R for the report route.")
