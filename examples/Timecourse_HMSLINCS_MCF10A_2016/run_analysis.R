# Run the gDR Incucyte report on the HMS LINCS MCF10A time course.
#
# The reports themselves are the ones shipped with gDR - this example only
# supplies the data, the plate map and the analysis config. Run prepare_inputs.R
# first; it derives the manifest and template from the published plate table and
# rebases the instrument clock onto treatment start.

library(gDR)

wd <- getwd()
prepared <- file.path(wd, "prepared")
if (!dir.exists(prepared)) {
  source(file.path(wd, "prepare_inputs.R"))
}

templates <- system.file("report_templates", package = "gDR")
stopifnot(nzchar(templates))

run_report(
  manifest = file.path(prepared, "manifest_20160421.xlsx"),
  treatment = file.path(prepared, "Template_20160421_308.xlsx"),
  raw_data = paste(list.files(prepared, pattern = "total\\.txt$", full.names = TRUE),
                   collapse = ","),
  configuration_file_path = file.path(wd, "raw_data", "time_course_plot_params.yml"),
  # the incucyte directory comes first so its steps win over the shared set
  rmd_template_path = c(file.path(templates, "incucyte"), templates),
  output_dir = file.path(wd, "report"),
  embed = TRUE
)
