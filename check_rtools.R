# Increase the download timeout (default is 60 seconds, which is too short for a ~500MB Rtools file)
options(timeout = 1000)

if (!requireNamespace("pkgbuild", quietly = TRUE)) {
  install.packages("pkgbuild", quiet = TRUE)
}

if (pkgbuild::has_rtools()) {
  message("✅ Rtools is correctly installed and ready to use.")
  
} else {
  message("❌ Rtools not detected. Starting download and installation...")
  message("⏳ Downloading Rtools (approx. 500 MB). This may take a few minutes...")

  if (!requireNamespace("installr", quietly = TRUE)) {
    install.packages("installr", quiet = TRUE)
  }
  installr::install.Rtools()
  
  message("⚠️ IMPORTANT: After the Rtools installation is complete, restart your R session (in RStudio: Session -> Restart R) so the system recognizes the changes!")
}