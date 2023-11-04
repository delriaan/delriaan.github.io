
# Load libraries ----
spsUtil::quiet({
  library(rlang, include.only = "%||%")
  library(book.of.workflow); 
  load_unloaded(httr, magrittr, purrr, stringi, jsonlite, stringdist, htmltools, plotly, book.of.utilities, book.of.features, "data.table{+%between%}")
});

# Retrieve code from a local Git repository ----
dir(
  path = ifelse(Sys.getenv('GIT_REPOS') == '', Sys.getenv('GIT_Imperial'), Sys.getenv('GIT_REPOS'))
  , pattern = "(javascript|footer).+R$"
  , recursive = TRUE
  , full.names = TRUE
  ) |> 
  walk(source);

# Create local resources ----
message(getOption("article"));

if (grepl("dataset.+temporal", c(getOption("article"), "")[1])){
  list(
    window_example.png = "./window_example.png"
    , waypoint.png = "./waypoint.png"
    ) |> 
    iwalk(\(i, j){ 
      if (file.exists(i)){ 
        assign(j, magick::image_resize(magick::image_read(i), geometry = magick::geometry_size_percent(20)), envir = .GlobalEnv);
      }
    });
  
  problem_statement <- { tags$span(
    class = "speech"
    , style = "font-size: 0.9em; "
    , "\"I want to know trends related to total cost of care; Inpatient average lengths of stay; lapses in medication adherence; and member counts for the period between January first of 2019 and the end of 2020. Med lapses should show monthly totals and cumulative monthly totals. Pull members between 30 and 50 years old and have had at least two Inpatient visits within a six-week period. I need to see results by month; all services received and corresponding facilities; and member demographics.\""
    )}
  
  taxonomy <- { tags$p(
    tags$ul(
      toggleGroup = "0"
      , context = "definition"
      , tags$li(
          tags$span(class='def_sym', HTML("&delta;<sup>I</sup>"))
          , ": Information-carrying columns"
          )
      , tags$li(
          tags$span(class='def_sym', HTML("&delta;<sup>G</sup>"))
          , ": Grouping columns (categorical, descriptive)"
          )
      , tags$li(
          tags$span(class='def_sym', HTML("&delta;<sup>Y</sup>"))
          , ": Measurements (e.g., purchase price, height, product ratings)"
          )
      , tags$li(
          tags$span(class='def_sym', HTML("&delta;<sup>T</sup>"))
          , ": Temporal columns to include dates and temporal hierarchies"
          )
      , tags$li(
          tags$span(class='def_sym', HTML("&delta;<sup>E</sup>"))
          , ": Record life-cycle tracking columns (for example, effective dates in slowly changing dimension parlance)"
          )
      )
    )}
} else if (grepl("measurement.+scale", c(getOption("article"), "")[1])){
  three_cats.jpg <- magick::image_read("./3 cats.jpg") |>
    magick::image_resize(geometry = magick::geometry_size_percent(90));
}

last_mod <- tags$span(
    style='font-size:smaller; text-decoration:italic; color:#999999; '
    , glue::glue("Updated {format(Sys.time(), \"%Y-%m-%d %H:%M:%S\")}")
  );

invisible(hint_js(tags = "", toggle.options = list(open = "(show)", close = "[hide]")))

