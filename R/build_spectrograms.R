# Batch-generates a spectrogram PNG for every row in data/calls.csv whose
# audio_file exists in www/audio/. Run this after adding new clips, then
# re-render the site.
#
#   Rscript R/build_spectrograms.R

source("R/make_spectrogram.R")

calls <- read.csv("data/calls.csv", stringsAsFactors = FALSE)
dir.create("www/spectrograms", showWarnings = FALSE, recursive = TRUE)

for (i in seq_len(nrow(calls))) {
  wav_path <- file.path("www/audio", calls$audio_file[i])
  png_path <- file.path("www/spectrograms", calls$spectrogram_file[i])

  if (!file.exists(wav_path)) {
    warning("Skipping row ", i, ": missing audio file ", wav_path)
    next
  }

  make_spectrogram(wav_path, png_path)
  cat("Wrote", png_path, "\n")
}
