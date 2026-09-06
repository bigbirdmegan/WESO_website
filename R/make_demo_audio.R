# Generates two SYNTHETIC placeholder calls so the site has real audio/
# spectrograms to show out of the box. Delete this script's output once you
# swap in real WESO clips - see R/make_spectrogram.R for turning a real
# recording into a spectrogram PNG for the dictionary page.

library(tuneR)

out_dir <- "www/audio"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

sr <- 22050

# a single short hoot pulse
hoot <- function(freq, dur, sr) {
  t <- seq(0, dur, by = 1 / sr)
  env <- sin(pi * t / dur) ^ 2 # smooth on/off envelope
  sin(2 * pi * freq * t) * env
}

silence <- function(dur, sr) rep(0, round(dur * sr))

# --- "bouncing ball" primary song: pulses that speed up and shorten ---
gaps <- c(0.30, 0.28, 0.25, 0.22, 0.18, 0.15, 0.12, 0.10, 0.08, 0.07, 0.06, 0.05)
pulses <- lapply(gaps, function(g) c(hoot(420, 0.06, sr), silence(g, sr)))
bouncing_ball <- unlist(pulses)
bouncing_ball <- bouncing_ball / max(abs(bouncing_ball))
Wave1 <- Wave(left = bouncing_ball * 32000, samp.rate = sr, bit = 16)
writeWave(Wave1, file.path(out_dir, "bouncing_ball.wav"))

# --- "double trill" duet: one trill, pause, a second higher-pitched trill ---
trill <- function(freq, n, gap, sr) unlist(lapply(seq_len(n), function(i) c(hoot(freq, 0.05, sr), silence(gap, sr))))
call1 <- trill(400, 6, 0.06, sr)
call2 <- trill(520, 6, 0.06, sr)
double_trill <- c(call1, silence(0.8, sr), call2)
double_trill <- double_trill / max(abs(double_trill))
Wave2 <- Wave(left = double_trill * 32000, samp.rate = sr, bit = 16)
writeWave(Wave2, file.path(out_dir, "double_trill.wav"))

cat("Wrote demo audio to", out_dir, "\n")
