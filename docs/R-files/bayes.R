bayes <- \(H, L, target = 1:length(H), state = 1:ncol(L)){
  #' Bayes Calculator
  #' 
  #' @param H One or more class probabilities within the sample space
  #' @param L A matrix of state likelihood with rows the same length as \code{H}. If given with dimension names, they will be preserved.
  #' @param target The index(es) of the target(s)
  #' @param state The index(es) of the state(s)
  #' 
  #' @return The posterior probability of the target given the state
  #' 
  #' @family Bayesian helpers
  
  # :: Validate:
  assertive::assert_all_are_true(c(
    # Conformed dimensions:
    nrow(L) == length(H)
    # Conformed targets:
    , length(target) <= length(H)
    # Conformed states:
    , length(state) <= ncol(L)
    # Required libraries:
    , require(purrr)
    , require(magrittr)
    ));
  
  if (rlang::is_empty(dimnames(L))){
    dimnames(L) <- list(
      paste("prior", 1:nrow(L), sep = "_")
      , paste("evidence", 1:ncol(L), sep = "_")
      )
  }
  
  priors <- H[target];
  
  lk <- L[target, state, drop = FALSE];
  evidence <- apply(lk, 2, softmax);
  
  # :: Calculate:
  # browser()
  base_rate <- priors %*% evidence;
  
  likelihood <- as.matrix(priors * evidence, dimnames = dimnames(lk));
  
  posteriors <- as.matrix(likelihood / as.vector(base_rate), dimnames = dimnames(L));
  
  # :: Return:
  res <- list(
    priors = priors |> t()
    , posteriors = posteriors
    , posterior_odds = posteriors/priors
    )
  
  purrr::modify_at(res, c("posteriors", "posterior_odds"), \(x){ 
    magrittr::set_attr(x, "dimnames", list(names(priors  ), colnames(x))) 
  })
}

softmax <- \(x, as_array = FALSE, decimals = 6){
  if (as_array){ 
    x <- as.matrix(x)
  }
  round(exp(x) / sum(exp(x)), decimals);
}

new_posteriors <- \(m){ 
  sapply(1:ncol(m), \(i){
      if (i == 1){ 
        m[, i, drop = FALSE] 
      } else { 
        m[, c(i, i - 1), drop = FALSE] |> 
          matrixStats::rowProds() |> 
          softmax() 
      }
    }) %>% 
    .[, ncol(m)] |> 
    rlang::set_names(rownames(m))
  }
