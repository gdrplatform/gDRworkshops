# Turn the published HMS LINCS release into gDR inputs.
#
# Everything in raw_data/ is exactly as published. This script derives what gDR
# needs and writes it to prepared/, leaving the originals untouched. Three things
# have to happen before the pipeline can read the experiment:
#
#  1. The exports need a `Barcode` row. This release labels each plate with
#     `Label: <plate>` instead, and the loader takes the plate identifier from
#     the cell next to a `Barcode` key.
#  2. The plate map is published as a long table; gDR reads plate maps as
#     positional grids.
#  3. `Elapsed` counts from plating, not from treatment - and treatment starts
#     24 h later on three plates and 48 h later on the other three. The clock is
#     rebased here so that time zero is the first image after dosing.
#
# The prepared exports are written as .xlsx rather than text. A worksheet has
# explicit cells, so the metadata preamble and the much wider data block coexist
# without the field-count mismatch that makes `fread` skip the preamble in the
# published .txt files. It is also the format every current instrument export
# arrives in.

library(data.table)
library(writexl)

wd <- getwd()
raw <- file.path(wd, "raw_data")
out <- file.path(wd, "prepared")
dir.create(out, showWarnings = FALSE)

# --- 1 + 3. instrument exports ------------------------------------------------

prepare_export <- function(path, t0_nominal) {
  txt <- readLines(path, warn = FALSE)
  hdr <- grep("^Date Time", txt)[1]
  label <- trimws(sub("^[^:]*:", "", txt[1]))

  body <- data.table::fread(text = paste(txt[hdr:length(txt)], collapse = "\n"))
  # snap to the image nearest T0 rather than subtracting the nominal offset:
  # the imaging grid does not land on the dosing hour, and normalize_SE_time_course()
  # anchors on an exact zero
  t0 <- body$Elapsed[which.min(abs(body$Elapsed - t0_nominal))]
  body <- body[Elapsed >= t0]
  body[, Elapsed := round(Elapsed - t0, 4)]

  # One unnamed sheet: the original preamble kept as provenance, a `Barcode` row
  # added, then the data block. The loader scans the first column for its two
  # markers, so the sheet must carry no column names of its own - hence
  # everything as character and col_names = FALSE below.
  ncol <- ncol(body)
  as_row <- function(...) {
    cells <- c(...)
    c(cells, rep(NA_character_, ncol - length(cells)))
  }

  preamble <- lapply(txt[seq_len(hdr - 1L)], function(l) as_row(l))
  preamble <- append(preamble, list(as_row("Barcode", label)), after = 1L)

  sheet <- rbind(
    do.call(rbind, preamble),
    as_row(names(body)[1], names(body)[-1]),
    as.matrix(body[, lapply(.SD, as.character)])
  )

  dest <- file.path(out, sub("\\.txt$", ".xlsx", basename(path)))
  writexl::write_xlsx(as.data.frame(sheet, stringsAsFactors = FALSE), dest,
                      col_names = FALSE)
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
