if (!exists("get_resource", envir = rlang::caller_env())){
  Sys.getenv("GIT_REPOS") |> file.path("resources/R/get_resource.R") |> source()
}

if (!exists("get_user_agent")){
  Sys.getenv("GIT_REPOS") |> file.path("resources/R/user_agents.R") |> source()
}
 
calc_adherence <- \(measure = c("MPR", "CMA", "CMG", "CSA", "CSG", "2", "7"), days_supply, service_date, .debug = FALSE){
  #' Medication Adherence Calculator
  #' 
  #' @param measure A measure identifer as found in global object \code{adherence_measures}
  #' @param days_supply,service_date The days of supply and dates of fill, respectively: all arguments should be of the same length.
  #' 
  #' @return A vector of adherence values
  #' 
  #' @note Negative values may indicate a true lapse but may also stem from data partitioning and sequencing in the parent context.
  #' @note Default values per measure are used when NA or infinite values are detected in the penultimate result.
  #' 
  #' @references
  #' Lam, Wai Yin, Fresco, Paula, Medication Adherence Measures: An Overview, BioMed Research International, 2015, 217047, 12 pages, 2015. https://doi.org/10.1155/2015/217047
  measure <- match.arg(measure)

  assertive::assert_all_are_same_length(days_supply, service_date)

  dT <- c(days_supply[1], diff(as.numeric(service_date)))
  fill_gap <- dT - days_supply

  # Evaluated equation definitions:
  eqns <- list(
      MPR = days_supply/(dT + fill_gap)
      , CMA = cumsum(days_supply) / cumsum(dT + fill_gap)
      , CMG = (\(x) ifelse(x < 0, 0, x))(cumsum(fill_gap)/cumsum(dT))
      , CSA = days_supply/dT
      , CSG = sum(fill_gap)/sum(dT)
      , `2` = NA
      , `7` = NA
      )

  # Default values:
  dflts <- c(MPR = 0, `2` = NA, CMA = 1, CMG = 0, CSA = 0, CSG = 0, `7` = NA)

  if (.debug) browser()
  
  eqns[[measure]] |>
    purrr::modify_if(\(x) is.na(x) | is.infinite(x), ~dflts[measure])
}

get_adherence_defs <- \(browser_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"){
  #' Retrieve Medication Adherence Definitions
  #' 
  #' @references https://onlinelibrary.wiley.com/doi/10.1155/2015/217047
  #' 
  
  cookies <- "cookies.txt"
  
  med_adherence_web_resp <<- "https://doi.org/10.1155/2015/217047" |>
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
    purrr::map(\(i){
      med_adherence_web_resp |>
      rvest::html_element(glue::glue("#sec-{i}")) |>
      rvest::html_children() |>
      purrr::map(rvest::html_text, trim = TRUE) |>
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
  
  adherence_measures <<- adherence_measures[tmp_obj, on = "meas_id"] |>
    data.table::setcolorder("description", after = "equation") |>
    data.table::setattr("url", "https://doi.org/10.1155/2015/217047")
  
  sapply(c("med_adherence_web_resp", "adherence_measures"),\(x) exists(x, envir = rlang::caller_env())) |>
    assertive::assert_all_are_true()
  
  rm(tmp_obj)
}
