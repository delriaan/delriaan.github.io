make_regex <- \(x, .regex = c("[0-9]", "[a-z]", "[A-Z]", "[.]"), ...){
  #' Make Regular Expression Patterns
  #' This function reads in text and, using the patterns passed to argument \code{.regex}, creates regex patterns based on matching pattern segments.
  #' 
  #' @param x (string[]) One or more strings to process.
  #' @param .regex (string[]) One or more patterns to check against \code{x}
  #' @param ... (\code{\link[rlang]{dots_list}}) Additional patterns to append to \code{.regex}

  inner_progress <- list(format = "{cli::pb_bar}{cli::pb_percent} [{cli::pb_elapsed_clock}] | ETA {cli::pb_eta}")
  .regex <- c(.regex, rlang::enexprs(...) |> as.character()) |> unique()

  finalize <- \(x){
    architect::define(
      x
      , na.omit(.SD)[(start > 0)]
      , event.vectors::continuity(
          data = .SD
          , map_fields = c(regex)
          , time_fields = c(start, end)
          , timeout = 1
          , boundary_name = "window"
          , show.all = TRUE
          )
      , ~regex + window_start_idx
      , .(regex_ct = .N) ~ regex + window_start_idx
      , unique(.SD)
      , out := sprintf("%s{%s}", regex, regex_ct) |>
          paste(collapse = "") |>
          stringi::stri_replace_all_fixed("{1}", "", vectorise_all = FALSE)
      )
  }

  stringi::stri_replace_all_regex(x, .regex, .regex, vectorize_all = FALSE) |>
    unique() |>
    rlang::set_names() |>
    purrr::map(\(s){
      stringi::stri_locate_all_fixed(s, .regex) |>
        rlang::set_names(.regex) |>
        lapply(as.data.table) |>
        data.table::rbindlist(idcol = "regex") |>
        setkey(start) |>
        finalize()
      }, .progress = inner_progress) |>
    data.table::rbindlist(idcol = "pattern_id")
}
