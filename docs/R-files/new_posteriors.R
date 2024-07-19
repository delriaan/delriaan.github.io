new_posteriors <- \(m){ 
  #' Return New Posteriors from Prior Calculation
  #' 
  #' 
  #' @family Bayesian helpers
  assertive::assert_all_are_true(c(
    # Required Libraries
    require(matrixStats)
    ))

  sapply(1:ncol(m), \(i){
      if (i == 1){ 
        m[, i, drop = FALSE] 
      } else { 
        m[, c(i, i - 1), drop = FALSE] |> 
          matrixStats::rowProds() |> 
          softmax() 
      }
    }) |>
    (`[`)(, ncol(m)) |> 
    rlang::set_names(rownames(m))
  }