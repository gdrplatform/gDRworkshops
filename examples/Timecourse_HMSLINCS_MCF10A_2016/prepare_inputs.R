# Turn the published HMS LINCS release into gDR inputs.
#
# Everything in raw_data/ is exactly as published. This script derives what gDR
# needs and writes it to prepared/, leaving the originals untouched. Three things
# have to happen before the pipeline can read the experiment:
#
#  1. The Incucyte exports need a `Barcode` row, and their metadata preamble has
#     to be padded to the width of the data block or `fread` skips it.
#  2. The plate map is published as a long table; gDR reads plate maps as
#     positional grids.
#  3. `Elapsed` counts from plating, not from treatment - and treatment starts
#     24 h later on three plates and 48 h later on the other three. The clock is
#     rebased here so that time zero is the first image after dosing.

library(data.table)
library(writexl)

wd <- getwd()
raw <- file.path(wd, "raw_data")
out <- file.path(wd, "prepared")
dir.create(out, showWarnings = FALSE)

# --- 1 + 3. instrument exports ------------------------------------------------

# strsplit() drops a trailing empty field, so count separators instead
n_fields <- function(l) nchar(l) - nchar(gsub("\t", "", l, fixed = TRUE)) + 1L

prepare_export <- function(path, t0_nominal) {
  txt <- readLines(path, warn = FALSE)
  hdr <- grep("^Date Time", txt)[1]
  ncol <- n_fields(txt[hdr])
  label <- trimws(sub("^[^:]*:", "", txt[1]))

  body <- data.table::fread(text = paste(txt[hdr:length(txt)], collapse = "\n"))
  # snap to the image nearest T0 rather than subtracting the nominal offset:
  # the imaging grid does not land on the dosing hour, and normalize_SE_time_course()
  # anchors on an exact zero
  t0 <- body$Elapsed[which.min(abs(body$Elapsed - t0_nominal))]
  body <- body[Elapsed >= t0]
  body[, Elapsed := round(Elapsed - t0, 4)]

  # keep the original preamble as provenance, add the barcode row gDR looks for.
  # It cannot be line 1: fread(header = TRUE) reads that as column names.
  pre <- append(txt[seq_len(hdr - 1L)], paste0("Barcode\t", label), after = 1L)
  pre <- vapply(pre, function(l) paste0(l, strrep("\t", max(0L, ncol - n_fields(l)))),
                character(1), USE.NAMES = FALSE)

  dest <- file.path(out, basename(path))
  writeLines(pre, dest)
  data.table::fwrite(body, dest, sep = "\t", append = TRUE, col.names = TRUE)
  dest
}

plate_tab <- fread(file.path(raw, "20160421_MCF10A LINCS_drug response live_plateID.tsv"))
plate_tab[, t0_nominal := as.numeric(difftime(
  as.POSIXct(sub("(\\d)(am|pm)$", "\\1:00 \\2", T0date), format = "%Y-%m-%d %I:%M %p", tz = "UTC"),
  as.POSIXct(sub("(\\d)(am|pm)$", "\\1:00 \\2", Tplate_Date), format = "%Y-%m-%d %I:%M %p", tz = "UTC"),
  units = "hours"))]
stopifnot(all(plate_tab$t0_nominal > 0))

results_files <- vapply(seq_len(nrow(plate_tab)), function(i) {
  f <- list.files(raw, pattern = paste0("^", plate_tab$Barcode[i], " total\\.txt$"), full.names = TRUE)
  stopifnot(length(f) == 1L)
  prepare_export(f, plate_tab$t0_nominal[i])
}, character(1))

# --- 2. plate map and manifest ------------------------------------------------

layout <- fread(file.path(raw, "Layout_20160421_308.tsv"))

n_row <- 16L
n_col <- 24L
grid_of <- function(values) {
  m <- matrix(NA_character_, n_row, n_col)
  m[cbind(match(substr(layout$Well, 1, 1), LETTERS),
          as.integer(substring(layout$Well, 2)))] <- as.character(values)
  as.data.frame(m)
}

# "DrugName" is reserved for pipeline output, so the readable name goes into the
# drug identifier sheet and the HMS id rides along as extra well metadata
is_vehicle <- layout$pert_type == "ctl_vehicle"
template_file <- file.path(out, "Template_20160421_308.xlsx")
write_xlsx(list(
  Gnumber       = grid_of(fifelse(is_vehicle, "vehicle", layout$DrugName)),
  Concentration = grid_of(fifelse(is_vehicle, "0", as.character(layout$Conc))),
  HMSLid        = grid_of(fifelse(is_vehicle, "-", layout$HMSLid))
), template_file, col_names = FALSE)

manifest_file <- file.path(out, "manifest_20160421.xlsx")
write_xlsx(data.table(
  Barcode       = plate_tab$Barcode,
  Template      = basename(template_file),
  clid          = "MCF10A",
  Duration      = NA_real_,   # required by the schema; timepoints come from the exports
  plating_delay = plate_tab$plating_delay,
  T0date        = plate_tab$T0date
), manifest_file)

message(sprintf("prepared %d plates, %d wells -> %s",
                nrow(plate_tab), nrow(layout), out))
