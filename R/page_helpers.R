# Shared helpers used at the top of each page's .Rmd.

# Prints a full-width banner image for the current page, if one exists.
# Looks for www/banners/<name>.jpg, .jpeg, .png, or .webp - drop a photo in
# there with the matching name and it'll show up on next render, no code
# changes needed. Prints nothing if the file isn't there yet.
show_banner <- function(name, alt = name) {
  exts <- c("jpg", "jpeg", "png", "webp")
  for (ext in exts) {
    path <- file.path("www/banners", paste0(name, ".", ext))
    if (file.exists(path)) {
      cat('<img class="page-banner" src="', path, '" alt="', htmltools::htmlEscape(alt), '">\n', sep = "")
      return(invisible(NULL))
    }
  }
  invisible(NULL)
}

# Prints a small round headshot for a team member, if one exists. Looks for
# www/team/<name>.jpg, .jpeg, .png, or .webp. Prints nothing if missing.
show_team_photo <- function(name, alt = name) {
  exts <- c("jpg", "jpeg", "png", "webp")
  for (ext in exts) {
    path <- file.path("www/team", paste0(name, ".", ext))
    if (file.exists(path)) {
      cat('<img class="team-photo" src="', path, '" alt="', htmltools::htmlEscape(alt), '">\n', sep = "")
      return(invisible(NULL))
    }
  }
  invisible(NULL)
}

# Prints one team member's photo + name + bio on the About page. Call this
# once per person, e.g.:
#   team_member("Megan Buers", photo = "meganbuers_bio", bio = "...")
# `photo` is the filename (without extension) of a photo in www/team/, or
# leave it NULL if you don't have one yet.
team_member <- function(name, bio, photo = NULL) {
  cat('<div class="team-member">\n')
  if (!is.null(photo)) show_team_photo(photo, name)
  cat('<div class="team-bio">\n')
  cat('<h2>', htmltools::htmlEscape(name), '</h2>\n', sep = "")
  cat('<p>', htmltools::htmlEscape(bio), '</p>\n', sep = "")
  cat('</div>\n')
  cat('</div>\n')
}
