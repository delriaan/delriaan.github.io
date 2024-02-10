library(book.of.workflow)
load_unloaded(magrittr, rsvg, plotly, purrr, book.of.utilities, book.of.features)
#
# :: ----
dir(
  path = dirname(rstudioapi::getSourceEditorContext()$path)
  , pattern = "^[0-9].+Rmd"
  # , full.names = TRUE
  ) |>
  map_chr(\(x){
    text <- rmarkdown::yaml_front_matter(x)$title |> stringi::stri_split_fixed(" - ", simplify = TRUE) %>% .[length(.)];
    htmltools::tags$td(text)
  })
