recycle <- \(vals, out.length){
  #' Recycle a Value
  #'
  #' @param vals A vector of values
  #' @param out.length An integer indicating the output length: \code{vals} will be recycled to this length.
  vals[(c(1:n) - 1) %% length(vals) + 1]
}
