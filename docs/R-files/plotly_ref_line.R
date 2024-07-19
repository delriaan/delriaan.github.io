plotly_ref_line <- function(..., type = NULL, color = "black", dash ="dot", size = 20) {
  #' Create a \code{plotly} Reference Line
  #' 
  #' (see \url{https://plotly.com/r/horizontal-vertical-shapes/})
  #'
  #' @param ... The reference coordinate(s): any of \code{x0}, \code{x1}, \code{y0}, \code{y1}, \code{xref}, \code{yref}
  #' @param type (string, symbol | \code{NULL}) The 'type of line: \code{hline}, \code{vline}, or \code{NULL}
  #' @param color (string) A valid color 
  #' @param dash (string) A valid line dash type
  #' @param dash (numeric) A valid line sizes
  #' 
  #' @return A \code{plotly} reference line definition for use in \code{plotly::layout(shapes = ...)}
  
  type = as.character(rlang::enexpr(type));
  
  if (rlang::is_empty(type)){ type <- "" }
  
  .out = list(x0 = 0, y0 = 0, x1 = 0, y1 = 0
              , xref = "paper", yref = "paper"
              , line = list(color = color, dash = dash, size = size)
              );
  .nms = intersect(names(.out), unlist(...names()));
  
  if (!rlang::is_empty(.nms)){ .out[.nms] <- list(...)[.nms]; }
  if (!all(c(.out[c("x0", "x1")] %between% list(0, 1)))){ .out$xref = "x" }
  if (!all(c(.out[c("y0", "y1")] %between% list(0, 1)))){ .out$yref = "y" }
  
  if (type == "hline"){
    .out[c("x0", "x1")] <- list(0, 1);
  } else if (type == "vline"){ 
    .out[c("y0", "y1")] <- list(0, 1);
  } else { invisible() }
  
  return(.out);
}
#
