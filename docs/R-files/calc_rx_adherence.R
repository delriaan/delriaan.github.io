# Adherence calculation methods:
calc_adherence <- \(data, measure = c("MPR", "2", "CMA", "CMG", "CSA", "CSG", "7")){
  #' Medication Adherence Calculator
  #' 
  #' @param data The input data created from `project.qmd::COMBINE_RX_SW_PROFILE_DATA`
  #' @param measure A measure identifier as found in global object \code{adherence_measures}
  #' 
  #' @return A vector of adherence values
  #' 
  #' @references
  #' Lam, Wai Yin, Fresco, Paula, Medication Adherence Measures: An Overview, BioMed Research International, 2015, 217047, 12 pages, 2015. https://doi.org/10.1155/2015/217047
  measure <- match.arg(measure)

  eqns <- rlang::quos(
      MPR = purrr::modify_if(1 - fill_gap/days_supply, \(x) is.na(x)|is.infinite(x), ~NA)
      , `2` = NA
      , CMA = NA
      , CMG = NA
      , CSA = NA
      , CSG = NA
      , `7` = NA
      )

  rlang::eval_tidy(eqns[[measure]], data = rlang::as_data_mask(data))
}

if (FALSE){
# <snippet: med adherence data :: Medication Adherence (https://onlinelibrary.wiley.com/doi/10.1155/2015/217047)> ----
  read.snippet(action = save, doc = NULL, med, adherence, data);
  if (!exists("get_resource")){
    Sys.getenv("GIT_REPOS") |> file.path("resources/R/get_resource.R") |> source()
  }

  if (!exists("get_user_agent")){
    Sys.getenv("GIT_REPOS") |> file.path("resources/R/user_agents.R") |> source()
  }
  
  cookies <- "cookies.txt"
  browser_agent <- get_user_agent()
  
  med_adherence_web_resp <- "https://doi.org/10.1155/2015/217047" |>
    httr2::request() |>
    httr2::req_user_agent(browser_agent) |>
    httr2::req_cookie_preserve(path = cookies) |>
    httr2::req_headers(
      Origin = "https://onlinelibrary.wiley.com"
      , Accept = "text/html, */*; q=0.01"
      , "Accept-Language" = "en-US,en;q=0.9,gl;q=0.8,ja;q=0.7,fr;q=0.6"
      , Referer = "https://onlinelibrary.wiley.com/doi/10.1155/2015/217047"
      , Priority = "u=0, i"
      , "sec-ch-ua" = '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"'
      , "sec-ch-ua-mobile" = "?0"
      , "sec-ch-ua-platform" = "Windows"
      , "sec-fetch-dest" = "document"
      , "sec-fetch-mode" = "navigate"
      , "sec-fetch-site" = "none"
      , "sec-fetch-user" = "?1"
      , "sec-gpc" = 1
      , "upgrade-insecure-requests" = 1
      ) |>
    httr2::req_options(followlocation = 1) |>
    # httr2::req_dry_run()
    httr2::req_perform() |>
    httr2::resp_body_html() 
  
  adherence_measures <- stringi::stri_pad_left(5:10, width = 4, pad = "0") |>
    map(\(i){
      med_adherence_web_resp |>
      rvest::html_element(glue::glue("#sec-{i}")) |>
      rvest::html_children() |>
      map(rvest::html_text, trim = TRUE) |>
      rlang::set_names(c("measures", "description"))
    }) |>
    data.table::rbindlist() |>
    architect::define(
      meas_id := stringi::stri_extract_last_regex(measures, "[A-Z]{3}") |>
        (\(x) ifelse(is.na(x), seq_along(x), x))()
      , ~meas_id + description
      )
  
  tmp_obj <- med_adherence_web_resp |>
    rvest::html_element("#tbl-0001") |>
    rvest::html_table() |>
    data.table::as.data.table() |>
    architect::define(
      data.table::setnames(.SD, tolower(names(.SD)))
      , .SD[(measures != "")]
      , purrr::map(.SD, \(x) textclean::replace_white(x) |> trimws())
      , meas_id := stringi::stri_extract_last_regex(measures, "[A-Z]{3}") |>
        (\(x) ifelse(is.na(x), seq_along(x), x))()
      , ~measures + meas_id + equation
      )
  
  adherence_measures <- adherence_measures[tmp_obj, on = "meas_id"] |>
    data.table::setcolorder("description", after = "equation") |>
    data.table::setattr("url", "https://doi.org/10.1155/2015/217047")
  
  sapply(c("med_adherence_web_resp", "adherence_measures"),\(x) exists(x, envir = rlang::caller_env())) |>
    assertive::assert_all_are_true()
  
  rm(tmp_obj)
# </snippet>
}
