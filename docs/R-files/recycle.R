recycle <- \(vals, out.length){
  #' Recycle a Value
  #'
  #' @param vals A vector of values
  #' @param out.length An integer indicating the output length: \code{vals} will be recycled to this length.
  vals[(seq_len(out.length) - 1) %% length(vals) + 1]
}
