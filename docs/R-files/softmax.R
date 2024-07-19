softmax <- \(x, as_array = FALSE, decimals = 6){
  #' Calculate via Softmax
  #' 
  #' @family Bayesian helpers
  if (as_array){ 
    x <- as.matrix(x)
  }
  round(exp(x) / sum(exp(x)), decimals);
}

