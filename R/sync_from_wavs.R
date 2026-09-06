# Your one command for adding new recordings to the site.
#
# Drop new WAV clips into wavs/, then run:
#   source("R/sync_from_wavs.R")
#
# For every WAV in wavs/ not already logged, this:
#   - copies it into www/audio/ (so the site can play it)
#   - generates a spectrogram PNG into www/spectrograms/
#   - adds a row to data/call_log.xlsx with a guessed call_type and blank
#     context/location/date/description columns for you to fill in
#
# It will NOT overwrite anything you've already typed into call_log.xlsx -
# only new WAVs get new rows. Open the spreadsheet, fill in the blanks, save
# it, and run this script again: it also regenerates data/calls.csv (what
# the website actually reads) from the current contents of the spreadsheet,
# every time it runs.
#
# After that, rebuild the site: Build > Build Website in RStudio, or
#   rmarkdown::render_site()

library(readxl)
library(writexl)
source("R/make_spectrogram.R")

wav_dir <- "wavs"
audio_dir <- "www/audio"
spectro_dir <- "www/spectrograms"
log_path <- "data/call_log.xlsx"

dir.create(audio_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(spectro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE, recursive = TRUE)

guess_call_type <- function(filename) {
  name <- tools::file_path_sans_ext(filename)
  name <- gsub("(?i)wesomac|wesoke", "", name, perl = TRUE)
  name <- gsub("[_\\.\\-]+", " ", name, perl = TRUE)
  name <- trimws(name)
  sub("^(.)", "\\U\\1", name, perl = TRUE)
}

wav_files <- list.files(wav_dir, pattern = "\\.wav$", ignore.case = TRUE)

log_cols <- c("filename", "call_type", "context", "location", "date", "description")
if (file.exists(log_path)) {
  existing <- as.data.frame(read_excel(log_path), stringsAsFactors = FALSE)
  # tolerate columns you've removed by hand (e.g. deleted "context") - add
  # them back blank rather than erroring, so you can refill them later
  missing_cols <- setdiff(log_cols, names(existing))
  for (col in missing_cols) existing[[col]] <- ""
} else {
  existing <- setNames(data.frame(matrix(nrow = 0, ncol = length(log_cols))), log_cols)
}

new_files <- setdiff(wav_files, existing$filename)

for (f in new_files) {
  file.copy(file.path(wav_dir, f), file.path(audio_dir, f), overwrite = TRUE)
  png_name <- paste0(tools::file_path_sans_ext(f), ".png")
  make_spectrogram(file.path(audio_dir, f), file.path(spectro_dir, png_name))
  cat("New clip:", f, "\n")
}

if (length(new_files) > 0) {
  new_rows <- data.frame(
    filename = new_files,
    call_type = vapply(new_files, guess_call_type, character(1)),
    context = "",
    location = "",
    date = "",
    description = "",
    stringsAsFactors = FALSE
  )
  log <- rbind(existing[log_cols], new_rows)
} else {
  log <- existing[log_cols]
  cat("No new WAV files in", wav_dir, "\n")
}

write_xlsx(log, log_path)
cat("Call log:", log_path, "(", nrow(log), "entries )\n")

# Rebuild data/calls.csv (the file the website reads) from the current
# contents of the spreadsheet, including anything you've typed in.
calls <- data.frame(
  id = seq_len(nrow(log)),
  call_type = log$call_type,
  context = log$context,
  location = log$location,
  date = log$date,
  description = log$description,
  audio_file = log$filename,
  spectrogram_file = paste0(tools::file_path_sans_ext(log$filename), ".png"),
  stringsAsFactors = FALSE
)
write.csv(calls, "data/calls.csv", row.names = FALSE, na = "")
cat("Wrote data/calls.csv with", nrow(calls), "entries\n")
