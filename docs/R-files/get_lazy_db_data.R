get.lazy_db_data <- function(input, name = NULL, env = .GlobalEnv, key_cols = NULL, subset_n = NULL, arrow_write_callback = NULL){
  #' Get 'Lazy' Database Data
  #' 
  #' \code{get.lazy_db_data} retrieves the input \code{i} and saves it to the workspace according to \code{env} and \code{nm}.
  #' 
  #' @param input The input created from \code{\link[dplyr]{tbl}} objects and verbs
  #' @param name,env The target assignment object name and environment
  #' @param key_cols (string[]) Column names to use as keys: defaults to the first column of the data
  #' @param subset_n (numeric) The number of rows to return as a subset
  #' @param arrow_write_callback (function) A callback function to write the data to disk as an Arrow dataset. The function should be a wrapper for the desired function and take \code{dataset} as the first argument. 
  #' @param ... Additional arguments passed to \code{\link[arrow]{write_dataset}} (must bne provided if \code{as_parquet == TRUE})
  #' 
  #' @section arrow_write_callback:
  #' Additional arguments should be defaulted or dynamically set using objects in the environment of \code{get.lazy_db_data}. Data is only written to disk requiring the user to supply code to read the data into the session workspace.
  #' 
  #' @return A \code{\link[data.table]{data.table}} object
  
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(dplyr)
    , require(data.table)
    , require(cli)
    , require(spsUtil)
    , require(magrittr)
    , require(purrr)
    # Argument checks:
    , rlang::is_empty(arrow_write_callback) || is.function(arrow_write_callback)
    ))
  
  name <- if (missing(name)){ NULL } else { rlang::enexpr(name) |> rlang::as_label() }
  
  # Provide an alternative object name to avoid accidental overwrites or conflicts:
  alt_name <- ifelse(
    rlang::is_empty(name)
    , past0("new_data_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    , paste(name, format(Sys.time(), "%Y%m%d_%H%M%S"), sep = "_")
    );
  
  env_name <- rlang::enexpr(env) |> rlang::as_label();
  
  fun <- if (rlang::is_empty(subset_n)){ 
      \(x) dplyr::collect(x) 
    } else { 
      \(x) head(x, subset_n) %>% dplyr::collect() 
    }
  
  new_data <- spsUtil::quiet(fun(input)) %>%
    data.table::as.data.table(key = c(key_cols %||% names(.)), keep.rownames = FALSE) %>% 
    purrr::modify_at(purrr::keep(., bit64::is.integer64) |> names(), \(x) bit64::as.integer.integer64(x)) %>%
    purrr::modify_at(purrr::keep(., lubridate::is.POSIXct) |> names(), lubridate::as_date);
  
  # Results check:
  if (rlang::is_empty(new_data)){
    cli::cli_alert_danger("No data was retrieved from the database.")
    return(invisible())
  } else {
    if (rlang::is_empty(name)) magrittr::set_attr(new_data, "call", rlang::caller_call());
  }
  
  # Argument handling - `arrow_write_callback`:
  if (!rlang::is_empty(arrow_write_callback)){
    cli::cli_alert_info("Data is only written to disk requiring the user to supply code to read the data into the session workspace.");
    
    tryCatch(expr = {
        arrow_write_callback(new_data);
        cli::cli_alert_success("Success!");
      }, error = \(e){ 
        cli::cli_alert(e$message); 
        cli::cli_alert_info(glue::glue("Retrieved data will be saved in the global environment under the name {alt_name}"))
        assign(alt_name, new_data, envir = .GlobalEnv);
      });
  } else {
    assign(
      x = ifelse(rlang::is_empty(name), alt_name, name)
      , value = new_data
      , envir = env
      )
  }
}
#
as_callback <- \(fun, ...){
  # browser()
  args_list <- rlang::dots_list(..., .named = TRUE, .ignore_empty = "all", .homonyms = "last");
  call_tree <- fun
  formals(call_tree)[names(args_list)] <- args_list;
  
  return(call_tree)
}
