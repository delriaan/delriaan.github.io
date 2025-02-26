#| Extract Bible passage references
#| source("https://delriaan.github.io/R-files/get_Bible_references.R")

# :: BEGIN OMIT
if (FALSE){
  # Get the source repo:
  .resources <- Sys.getenv("GIT_REPOS") |>
    file.path("resources/R") |>
    git2r::repository()

  .resources$path |>
    fs::path_dir() |>
    dir(pattern = "resource.+R", full.names = TRUE, recursive = TRUE) |>
    source()

  # Get the publishing repo:
  .githubPages <- Sys.getenv("GIT_REPOS") |>
    file.path("delriaan.github.io") |>
    git2r::repository()

  # Copy to publishing repo
  .resources$path |>
    fs::path_dir() |>
    dir(pattern = "Bible.+R", full.names = TRUE, recursive = TRUE) |>
    readLines() |>
    . => .[-do.call(`:`, args = grepl(".+[:]{2} [BEGN]{2}", .) |> which() |> as.list() |> print())] |>
    cat(file = .githubPages$path |>
        fs::path_dir() |>
        dir(pattern = "resource.+R", full.names = TRUE, recursive = TRUE))
  }
# :: END OMIT

local({
  .pattern <- paste0(
    # Book number (optional)
    "([0-9[:space:]]+)?"
    # Book and chapter
    , "([A-Z][a-z]{1,20}[[:space:]])+[0-9]{1,3}"
    # No verse (optional)
    # , "([;[:space:]]+)?"
    # Anchor verse
    , "([:][0-9]{1,3})?"
    # Verse range (optional, use '.' instead of '-')
    , "(.[0-9]{1,3})?"
    # Verse range set (optional)
    , "([,;[:space:]]+[0-9]{1,3}([:][0-9]{1,3})?(.[0-9]{1,3})?)?"
    )

  # :: Read text from clipboard
  url <- svDialogs::dlgInput(message = "Enter web address, text, or 'clipboard' to read from the clipboard:", rstudio = FALSE)$res

  if (url == "clipboard" && grepl("Windows", osVersion)){
      cli::cli_alert_info("Reading from clipboard ...")
      doc <- readClipboard() |> paste(collapse = " ")
  } else {
    doc <- (\(x) if (stringi::stri_detect_regex(x, "^http")){
        cli::cli_alert_info("URL detected: {x}")
          res <- list()
          res$html <- rvest::read_html(x)
          res$title <- res$html |>
            rvest::html_element(xpath = "//title") |> 
            rvest::html_text2()

          res$plain <- res$html |>
            rvest::html_text2() |>
            stringi::stri_replace_all_fixed("&mdash;", "-", vectorize_all = FALSE) |>
            stringi::stri_replace_all_regex("\n|\t\r", " ", vectorize_all = FALSE)

          rlang::set_names(res$plain, res$title)
    } else { x }
      )(url)
  }

  # :: Extract patterns
    res <- stringi::stri_extract_all_regex(doc, .pattern, simplify = TRUE) |>
      purrr::reduce(c) |>
      na.omit() |>
      trimws() |>
      unique()

  # :: Show results and save to clipboard:
    bible_refs <<- list(passages = paste(res, collapse = "; "), doc = doc)
    print(bible_refs)

  if (grepl("Windows", osVersion)) {
    writeClipboard(paste(res, collapse = "; "))
  }
})
