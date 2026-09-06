# Turns one WAV clip into a spectrogram PNG for the call dictionary page.
#
# Usage (single file):
#   source("R/make_spectrogram.R")
#   make_spectrogram("www/audio/my_clip.wav", "www/spectrograms/my_clip.png")
#
# Usage (batch, driven by data/calls.csv):
#   Rscript R/build_spectrograms.R

library(tuneR)
library(seewave)

make_spectrogram <- function(wav_path, out_png, flim = c(0, 6)) {
  wave <- readWave(wav_path)

  nyquist_khz <- wave@samp.rate / 2000
  if (flim[2] > nyquist_khz) flim[2] <- nyquist_khz * 0.98

  png(out_png, width = 900, height = 400, res = 120)
  on.exit(dev.off())

  seewave::spectro(
    wave,
    flim = flim, # kHz range to show - WESO calls sit mostly under 2 kHz
    osc = FALSE,
    scale = FALSE,
    palette = seewave::reverse.gray.colors.1,
    grid = FALSE,
    collevels = seq(-40, 0, 1)
  )
}
