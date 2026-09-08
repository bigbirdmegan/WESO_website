# Shared helpers used at the top of each page's .Rmd.

# Finds <dir>/<name>.<ext> for the first extension that exists, or NULL.
find_image <- function(dir, name) {
  exts <- c("jpg", "jpeg", "png", "webp")
  for (ext in exts) {
    path <- file.path(dir, paste0(name, ".", ext))
    if (file.exists(path)) return(path)
  }
  NULL
}

# Prints a full-width banner image for the current page, if one exists.
# Looks for www/banners/<name>.jpg, .jpeg, .png, or .webp - drop a photo in
# there with the matching name and it'll show up on next render, no code
# changes needed. Prints nothing if the file isn't there yet.
show_banner <- function(name, alt = name) {
  path <- find_image("www/banners", name)
  if (!is.null(path)) {
    cat('<img class="page-banner" src="', path, '" alt="', htmltools::htmlEscape(alt), '">\n', sep = "")
  }
  invisible(NULL)
}

# Prints a small round headshot for a team member, if one exists. Looks for
# www/team/<name>.jpg, .jpeg, .png, or .webp. Prints nothing if missing.
show_team_photo <- function(name, alt = name) {
  path <- find_image("www/team", name)
  if (!is.null(path)) {
    cat('<img class="team-photo" src="', path, '" alt="', htmltools::htmlEscape(alt), '">\n', sep = "")
  }
  invisible(NULL)
}

# Prints a small partner/funder logo, if one exists. Looks for
# www/partners/<name>.jpg, .jpeg, .png, or .webp. Prints nothing if missing.
show_partner_logo <- function(name, alt = name) {
  path <- find_image("www/partners", name)
  if (!is.null(path)) {
    cat('<img class="partner-logo" src="', path, '" alt="', htmltools::htmlEscape(alt), '">\n', sep = "")
  }
  invisible(NULL)
}

# Italicizes scientific (binomial) names written like "(Genus species)" -
# the convention used after a common name, e.g. "Barred Owls (Strix varia)".
# Escape the text with htmltools::htmlEscape() first, then pass it through
# this, so the <em> tags added here don't get escaped too.
italicize_binomials <- function(text) {
  gsub("\\(([A-Z][a-z]+ [a-z]+)\\)", "(<em>\\1</em>)", text)
}

# Prints one funder/partner (logo if available, else just the name) on the
# Home page. `logo` is a filename (no extension) in www/partners/, or leave
# blank/NA. `url` is optional - if set, the logo/name links out to it.
partner_item <- function(name, logo = NULL, url = NULL) {
  has_url <- !is.null(url) && !is.na(url) && nchar(trimws(url)) > 0
  if (has_url) cat('<a class="partner" href="', htmltools::htmlEscape(url), '" target="_blank" rel="noopener">\n', sep = "")
  else cat('<div class="partner">\n')

  logo_path <- if (!is.null(logo) && !is.na(logo) && nchar(trimws(logo)) > 0) find_image("www/partners", logo) else NULL
  if (!is.null(logo_path)) {
    cat('<img class="partner-logo" src="', logo_path, '" alt="', htmltools::htmlEscape(name), '">\n', sep = "")
  } else {
    cat('<span class="partner-name">', htmltools::htmlEscape(name), '</span>\n', sep = "")
  }

  if (has_url) cat('</a>\n') else cat('</div>\n')
}

# Prints one team member's photo + name + bio on the About page. Call this
# once per person, e.g.:
#   team_member("Megan Buers", photo = "meganbuers_bio", bio = "...")
# `photo` is the filename (without extension) of a photo in www/team/, or
# leave it NULL/blank if you don't have one yet.
team_member <- function(name, bio, photo = NULL) {
  cat('<div class="team-member">\n')
  if (!is.null(photo) && !is.na(photo) && nchar(trimws(photo)) > 0) show_team_photo(photo, name)
  cat('<div class="team-bio">\n')
  cat('<h3>', htmltools::htmlEscape(name), '</h3>\n', sep = "")
  cat('<p>', italicize_binomials(htmltools::htmlEscape(bio)), '</p>\n', sep = "")
  cat('</div>\n')
  cat('</div>\n')
}
