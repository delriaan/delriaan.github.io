modify_ident <- function(id, ..., .debug = FALSE){ 
  #' Modify a Lazy T-SQL Identifier
  #' 
  #' A call to \code{modify_ident} modifies the identifier in the \bold{FROM} portion of an 
  #' MSSQL query.\cr\cr Table hints and aliases are the primary use cases.
  #' 
  #' @note This function has only been tested with MSSQL.
  #' 
  #' @param id A \code{\link[dplyr]{tbl}} reference object
  #' @param ... Strings containing valid \bold{FROM} syntax following a table source (see \href{https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16}{FROM clause plus JOIN, APPLY, PIVOT (Transact-SQL)})
  #' 
  #' @return A modified MSSQL identifier
  #' @examples
  #' \dontrun{
  #' tbl <- dplyr::tbl(con, "##gTemp")
  #' tbl |> modify_ident("(NOLOCK)")
  #' }
  
  if (.debug) browser();
  
  target <- vctrs::field(id$lazy_query$x, "table");
  result <- paste(target, c(...), sep = " ");
  vctrs::field(id$lazy_query$x, "table") <- result;
  
  # Mark the identifier as quoted since it is no longer a valid SQL identifier
  vctrs::field(id$lazy_query$x, "quoted") <- TRUE;
  
  id
}

