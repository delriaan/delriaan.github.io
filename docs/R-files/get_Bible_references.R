#| Extract Bible passage references
#| source("https://delriaan.github.io/R-files/get_Bible_references.R")

.resources <- Sys.getenv("GIT_REPOS") |>
  file.path("resources/R") |>
  git2r::repository()

.resources$path |> 
  fs::path_dir() |>
  dir(pattern = "resource.+R", full.names = TRUE, recursive = TRUE) |>
  source()

# :: Read text from clipboard
text <- svDialogs::dlgInput(message = "Enter web address, text, or 'clipboard' to read from the clipboard:", rstudio = FALSE)$res
if (text == "clipboard"){ 
  text <- readClipboard() |> paste(collapse = " ")
}

text <- (\(x) ifelse(stringi::stri_detect_regex(x, "^http"), {
      cli::cli_alert_info("URL detected: {x}")
      rvest::read_html(x) |> rvest::html_text() |> paste(collapse = "\n")
    }, x))(text) |>
  stringi::stri_replace_all_regex("\n|\t", " ", vectorize_all = FALSE) |> 
  paste(collapse = "")

# :: Extract patterns
  .pattern <- paste0(
    # Book number (optional)
    "([0-9[:space:]]+)?"
    # Book and chapter
    , "([A-Z][a-z]{1,20}[[:space:]])+[0-9]{1,3}"
    # No verse (optional)
    , "([;[:space:]]+)?"
    # Anchor verse
    , "([:][0-9]{1,3})?"
    # Verse range (optional)
    , "([-][0-9]{1,3})?"
    # Verse range set (optional)
    , "([,;[:space:]]+[0-9]{1,3}([:][0-9]{1,3})?([-][0-9]{1,3})?)?"
    )

  res <- stringi::stri_extract_all_regex(text, .pattern, simplify = TRUE) |> 
    purrr::reduce(c) |> 
    na.omit() |>
    trimws() |>
    unique()

# :: Show results and save to clipboard:
print(res)
writeClipboard(paste(res, collapse = "; "))
