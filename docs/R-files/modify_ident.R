modify_ident <- function(id, ..., query.only = FALSE, .debug = FALSE){ 
  #' Modify a Lazy T-SQL Identifier
  #' 
  #' A call to \code{modify_ident} modifies the identifier in the \bold{FROM} portion of an 
  #' MSSQL query.\cr\cr Table hints and aliases are the primary use cases.
  #' 
  #' @note This function has only been tested with MSSQL.
  #' 
  #' @param id A \code{\link[dplyr]{tbl}} reference object
  #' @param ... Strings containing valid \bold{FROM} syntax following a table source (see \href{https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16}{FROM clause plus JOIN, APPLY, PIVOT (Transact-SQL)})
  #' @param query.only (logical) Should the query be returned instead of the object?
  #' @param .debug \code{TRUE} launches the debugging environment browser
  #' 
  #' @return A modified MSSQL identifier
  #' 
  #' @examples
  #' \dontrun{
  #' tbl <- dplyr::tbl(con, "##gTemp")
  #' tbl |> modify_ident("(NOLOCK)")
  #' }
  #' 
  #' @export
  
  if (.debug) browser();

  res <- id$lazy_query$x
  vctrs::field(res, "table") <- paste(vctrs::field(res, "table"), c(...), sep = " ")

  # Mark the identifier as quoted since it is no longer a valid SQL identifier
  vctrs::field(res, "quoted") <- TRUE

  if (query.only){
    dplyr::show_query(id)
  } else { id }
}

