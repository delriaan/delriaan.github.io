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

  assertive::assert_are_same_length(days_supply, service_date)

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

get_adherence_defs <- \(html_source){
  #' Retrieve Medication Adherence Definitions
  #' 
  #' @references https://onlinelibrary.wiley.com/doi/10.1155/2015/217047
  #' 
  
  .adherence_measures_source <- html_source |>
    xml2::read_html() |>
    xml2::xml_find_first("//section[@id='3D\"sec-0004\"' and @class='3D\"article-section__content\"']")
  
  .tmp_obj <- .adherence_measures_source |>
      xml2::xml_find_first("//table") |>
      rvest::html_table() |>
      as.data.table() |>
      define(
        setnames(.SD, c("measure", "equation")) |> na.omit()
        , map(.SD, \(x) stri_enc_toascii(x) |> stri_replace_all_fixed("N/A", "", vectorize_all = FALSE) |> trimws())
        , map(.SD, stri_replace_all_regex, pattern = "((\r|\n)+)|([=][0-9A-Za-z]+)+|(?<=[[:space:]a-zA-Z]{1,3})[=]", replacement = "", vectorize_all = FALSE)
        , meas_id := stri_extract_first_regex(measure, "[A-Z]{3,4}") |> 
            (\(x){
              fifelse(
                is.na(x)
                , stri_trans_totitle(measure[is.na(x)]) |> 
                    stri_extract_all_regex("[A-Z]", simplify = TRUE) |> 
                    paste(collapse = "")
                , x
                )
            })() ~ measure
        )
    
  adherence_measures <- .adherence_measures_source |>
    xml2::xml_children() |>
    tail(6) |>
    map(\(ns){ 
      res <- xml2::xml_children(ns) |> 
        xml2::xml_text() |> 
        stri_enc_toascii() |> 
        stri_replace_all_regex(pattern = "((\r|\n)+)|([=][0-9A-Za-z]+)+|(?<=[[:space:]a-zA-Z]{1,3})[=]", replacement = "", vectorize_all = FALSE) |>
        trimws() |>
        paste(collapse = "|")
      
      meas_id <- stri_extract_first_regex(res, "[A-Z]{3,4}")
      if (res %ilike% "dichotomous"){ meas_id <- "DV" } else { stri_extract_first_fixed(adherence_measures$meas_id, res) }
        # (\(x){
        #     fifelse(
        #       is.na(x)
        #       , stri_trans_totitle(measure[is.na(x)]) |> 
        #           stri_extract_all_regex("[A-Z]", simplify = TRUE) |> 
        #           paste(collapse = "")
        #       , x
        #       )
        # })()
      
      list(meas_id = meas_id, description = res)
    }) |>
    append(list(list(meas_id = "PC", description = NA))) |>
    # purrr::flatten() |>
    rbindlist() |>
    _[.tmp_obj, on = "meas_id"] |>
    setcolorder("description", after = "equation")
}

