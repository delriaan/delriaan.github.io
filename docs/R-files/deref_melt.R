deref_melt <- memoise::memoise(\(variable, measure.vars){
  #' Dereference a 'Melted' Variable
  #' 
  #' This function takes the \code{variable} field from a \code{\link[data.table]{melt}} operation and dereferences it.
  #' 
  #' @param variable The contents of the \code{variable} field
  #' @param measure.vars The contents of what was provided to the \code{measure.vars} argument of \code{\link[data.table]{melt}}.
  #' 
  #' @return A length-two list:\cr
  #' \describe{
  #' \item{variable}{the variable passed to the function}
  #' \item{context}{A string or array of strings having format \code{<name: value>} delimited by ' | '}
  #' }
  res <- purrr::map_chr(
    variable
    , \(i){ 
        mv <- purrr::map(measure.vars, \(f) f[i] |> na.omit()) |> purrr::compact()
        imap_chr(mv, \(f, nm){  sprintf("<%s: %s>", nm, paste(f, collapse = "; ")) }) |>
          paste(collapse = " | ")
      }
    , .progress = TRUE
    )

  list(variable = variable, context = res)
}) |> 
compiler::cmpfun()
