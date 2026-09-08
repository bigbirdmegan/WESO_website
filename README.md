# WESOke Website

For the website of Megan Amy Buers and her research. A simple R Markdown website with a Western Screech-Owl call dictionary page.

## Structure

- `index.Rmd` - home page
- `call_dictionary.Rmd` - the call dictionary, built from `data/calls.csv`
- `data/calls.csv` - one row per call entry (type, context, location, date, description, audio/spectrogram filenames)
- `www/audio/` - audio clips (referenced by `audio_file` in the CSV)
- `www/spectrograms/` - spectrogram PNGs (referenced by `spectrogram_file` in the CSV)
- `R/make_spectrogram.R` - turns one WAV clip into a spectrogram PNG
- `R/build_spectrograms.R` - batch-generates spectrograms for every row in `calls.csv`
- `R/make_demo_audio.R` - generates the two synthetic placeholder clips currently on the page (delete once replaced)
- `wavs/` - drop new raw recordings here (not committed to git - see `R/sync_from_wavs.R`)
- `data/call_log.xlsx` - working spreadsheet for writing descriptions of each clip in `wavs/`
- `R/sync_from_wavs.R` - the main workflow script, see below
- `about.Rmd` / `publications.Rmd` - the About and Publications pages
- `data/team.xlsx` - one row per person on the About page (name, status, photo, bio - see below)
- `data/home_content.xlsx` - homepage content: `sections` (background/goal), `news`, `partners` sheets (see below)
- `www/banners/` - one photo per page for the banner at the top (see below)
- `www/team/` - headshots for the About page (see below)
- `www/partners/` - partner/funder logos for the homepage (see below)
- `www/logo.png` - your logo, shown in the navbar (see below)
- `logos/` - drop original/raw logo files here (not committed to git); process them into `www/logo.png` or `www/partners/<name>.png` (see below)
- `R/page_helpers.R` - the `show_banner()`, `show_team_photo()`, `show_partner_logo()`, `team_member()`, and `partner_item()` helpers used across pages
- `R/resize_image.R` - shrinks a photo for the web (use this on any new banner/team/partner photo - see below)

## Adding call entries from `wavs/`

This is the easiest way to add clips - it works from a spreadsheet instead of hand-editing the CSV:

1. Drop trimmed `.wav` clips into `wavs/`.
2. Run:
   ```r
   source("R/sync_from_wavs.R")
   ```
   For every WAV it hasn't seen before, this copies it into `www/audio/`, generates a spectrogram into `www/spectrograms/`, and adds a row to `data/call_log.xlsx` with a guessed `call_type` (from the filename) and blank `subspecies`/`context`/`location`/`date`/`description` columns.
3. Open `data/call_log.xlsx`, fill in the blanks, save it. If you type a filename in yourself instead of letting the script add the row, make sure it includes the `.wav` extension and matches the actual file exactly - a mismatch (or a missing extension) creates a duplicate blank row next sync instead of being recognized as the same clip.
4. Run `source("R/sync_from_wavs.R")` again - it re-reads the spreadsheet (new WAVs or not) and regenerates `data/calls.csv`, the file the website actually reads.
5. Generate spectrograms for any new rows: `source("R/build_spectrograms.R")`.
6. Re-render the site (see below).

`subspecies` (e.g. `M. k. macfarlanei`) is shown in italics alongside the context/location/date under each recorded example - leave it blank if you don't want it shown for a given clip.

Call types are grouped and ordered on the page as: Song, Double Trill, Barking, Begging, Food Delivery Call, Whinny, then anything else not in that list, with Abnormal Vocalisations always last. Edit the `type_order` vector in `call_dictionary.Rmd` to change the order or add more named types.

Re-running the script never overwrites anything you've already typed into the spreadsheet - it only adds rows for WAVs it hasn't logged yet.

## Adding a call entry by hand

If you'd rather skip the spreadsheet: trim the clip into `www/audio/`, add a row directly to `data/calls.csv`, then generate its spectrogram with `source("R/build_spectrograms.R")` (batches every row in the CSV) or `make_spectrogram()` from `R/make_spectrogram.R` for just the one file.

## Banner photos and logo

Drop image files in with these exact names and they'll show up automatically next render - no code changes needed:

| File | Where it appears |
|---|---|
| `www/banners/home.jpg` | Top of the Home page |
| `www/banners/about.jpg` | Top of the About page |
| `www/banners/call_dictionary.jpg` | Top of the Call Dictionary page |
| `www/banners/publications.jpg` | Top of the Publications page |
| `www/logo.png` | Small icon in the navbar, next to the site name |

Banners can be `.jpg`, `.jpeg`, `.png`, or `.webp`. They're displayed at a fixed height (320px) and cropped to fit, so landscape photos work best. A page with no banner file just skips it - nothing breaks.

The logo must be named exactly `www/logo.png` (see the `.navbar-brand` rule in `styles.css` if you want to use a different filename/format).

## Page background (margins)

The content column is centered and capped at 800px wide; whatever's outside it (the margins on either side, and above/below on short pages) shows `www/margin_bg.jpg` if present, or a solid fallback color otherwise. To change it: drop an image in as `www/margin_bg.jpg` (`.png`/`.webp` also work, just update the filename in the `html` rule in `styles.css`) and re-render - it's stretched to cover (`background-size: cover`), so a single photo/texture works better than something with important detail near the edges. To change just the fallback color (shown while the image loads, or if there's no image), edit the `background-color` value in that same `html` rule.

**Before adding a banner/team photo, shrink it for the web** - phone/camera photos are often 5-10MB at full resolution, way more than a webpage needs:

```r
source("R/resize_image.R")
resize_for_web("www/banners/home.jpg", max_width = 1600)
```

This overwrites the file in place as a compressed JPEG (a couple hundred KB to ~1MB instead of several MB), which keeps the site fast and the git repo small. Use `max_width = 800` for team photos.

**Logos need transparency, so use `resize_png_for_web()` instead** (keeps the PNG alpha channel rather than flattening to JPEG):

```r
source("R/resize_image.R")
resize_png_for_web("logos/your_logo.png", "www/logo.png", max_width = 300)
```

If a logo is the wrong color for the site (e.g. white on white), recolor it while keeping its transparency:

```r
library(magick)
img <- image_read("logos/your_logo.png")
alpha <- image_negate(image_channel(img, "opacity"))
solid <- image_blank(image_info(img)$width, image_info(img)$height, color = "black")
recolored <- image_composite(solid, alpha, operator = "CopyOpacity")
image_write(recolored, "www/partners/your_logo.png")
```

## Team members (About page)

The About page is built from `data/team.xlsx`, one row per person:

| Column | What goes in it |
|---|---|
| `name` | Their name, as shown on the page |
| `status` | `Current` or `Alumni` - controls which section they appear under |
| `photo` | Filename (no extension) of their headshot in `www/team/`, e.g. `meganbuers_bio` - leave blank for no photo |
| `bio` | A sentence or two about them |

To add someone: open `data/team.xlsx`, add a row, save it. If they have a headshot, resize it first (see above) and save it into `www/team/<something>.jpg`, matching whatever you put in the `photo` column. Re-render the site (see below) and they'll show up under Current Team or Alumni automatically - no code editing needed. People move between sections just by changing their `status` cell.

## Homepage content (background, goal, news, partners)

`data/home_content.xlsx` has three sheets, each shown on the Home page:

| Sheet | Columns | Notes |
|---|---|---|
| `sections` | `heading`, `body` | One row per paragraph block (e.g. "Background", "Our Goal"). Add more rows for more sections. The row headed exactly `Our Goal` gets special centered/italic styling (see the `featured` check in `index.Rmd` if you want to feature a different section instead). |
| `news` | `date`, `update`, `url` (optional) | One row per update, shown newest date first. Use `YYYY-MM-DD` dates so sorting works correctly. Leave `url` blank for plain text, or set it to make the update a clickable link. |
| `partners` | `name`, `logo` (optional), `url` (optional) | One row per funder/partner. `logo` is a filename (no extension) in `www/partners/`; leave blank to just show the name as text. `url` makes the logo/name a clickable link. |

Edit any sheet, save, and re-render - no code changes needed for new rows.

## Rendering the site

In RStudio: **Build > Build Website**, or from the console:

```r
rmarkdown::render_site()
```

This writes the HTML into `docs/`, which is what GitHub Pages serves.

## Publishing to GitHub Pages

1. Create a new GitHub repo and push this project to it.
2. On GitHub: **Settings > Pages** > set source to the `main` branch, `/docs` folder.
3. Add an empty `docs/.nojekyll` file (already included) so GitHub doesn't try to run Jekyll over the site.
4. In the repo's **Settings > Pages**, set the custom domain to `kennicottii.ca` (this also verifies the `CNAME` file at the project root, which `render_site()` copies into `docs/` on every build).
