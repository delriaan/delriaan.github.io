sql_date_range_str <- \(col, start, end, fmt = NULL){
  #' SQL Date Range String
  #' 
  #' @param col (string,symbol) The column name.
  #' @param start,end (string) The start and end dates, respectively.
  #' @param fmt An alternate \code{\link[glue]{glue}}-friendly template format that references any of the preceding arguments.
  #' 
  #' @return An object of class \code{SQL}.
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
