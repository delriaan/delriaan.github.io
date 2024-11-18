sql_date_range_str <- \(col, start, end, fmt = NULL){
  #' SQL Date Range String
  #' 
  #' This function produces a conditional SQL string in one of two forms:\cr
  #' \enumerate{
  #' \item{\code{col BETWEEN start AND end}}
  #' \item{\code{col[1] <= end AND col[2] >= start}}
  #' }
  #' 
  #' @param col (string,symbol) The column name: provide two columns by using \code{\link[base]{c}}
  #' @param start,end (string) The start and end dates, respectively.
  #' @param fmt An alternate \code{\link[glue]{glue}}-friendly template format that references any of the preceding arguments.
  #' 
  #' @return An object of class \code{SQL} that can be used with \code{\link[dplyr]{filter}} or additionally handled with string-processing functions.
  #' @export 
  #' 
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(DBI)
    ))
  col <- rlang::enexpr(col)
  
  if (is.call(col)){ 
    col <- as.list(col)[-1] |> sapply(as.character)
  } else {
    col <- as.character(col)
  }
  
  template <- list(
    between = "[{col}] BETWEEN '{start}' AND '{end}'"
    , overlap = "[{col[1]}] <= '{end}' AND [{col[2]}] >= '{start}'"
    );
  
  if (rlang::is_empty(fmt)){
    fmt <- template[[1 + (length(col) > 1)]]
  }
  
  DBI::SQL(glue::glue(fmt));
}
