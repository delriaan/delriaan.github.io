list2html <- function(i, .nm = NULL, .level = 0, .ordered = FALSE){
#' From R Lists to HTML Lists
#'
#' \code{list2html()} transforms an R list to an HTML list
#'
#' @param i (list) The input
#' @param .nm (string) The name of the current element (passively set on iteration)
#' @param .level (integer) The list level (passively set on iteration)
#' @param .ordered (logical)
  
  lfun = list(htmltools::tags$ul, htmltools::tags$ol)[[1 + .ordered]]
  
  if (!rlang::is_list(i)){
    htmltools::tags$li(
      level = .level
      , htmltools::tags$b(htmltools::HTML(.nm))
      , paste0(": ", paste(i, collapse = ", ")) |>
        htmltools::HTML() |>
        htmltools::tags$span()
      )
  } else {
    htmltools::tags$p(
      (list(
        \(x) htmltools::tags$li(style = 'font-weight:bold', htmltools::HTML(x), level = .level)
        , htmltools::tags$b
        )[[1 + (.level == 0)]])(.nm)
      , purrr::imap(i, \(x, y){ 
          list2html(i = x, .nm = y, .level = .level + 1, .ordered = .ordered) 
          }) |> 
        lfun()
      )
  }
}
