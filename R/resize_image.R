# Shrinks a photo for the web (banners/team photos don't need to be full
# camera resolution - they're displayed at a few hundred pixels tall).
# Overwrites the file in place as a compressed JPEG.
#
# Usage:
#   source("R/resize_image.R")
#   resize_for_web("www/banners/home.jpg", max_width = 1600)

library(magick)

resize_for_web <- function(path, max_width = 1600, quality = 82) {
  img <- image_read(path)
  img <- image_resize(img, paste0(max_width, "x"))
  img <- image_convert(img, format = "jpeg")
  image_write(img, path, quality = quality)
  cat(path, "->", format(file.info(path)$size / 1024, digits = 3), "KB\n")
}
