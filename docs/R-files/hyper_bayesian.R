hyper_bayesian <- \(hp_data, scoring_data, candidate_hps, score_expr, score_state, .debug = FALSE){
  #' Bayesian Hyper-parameter Search
  #' 
  #' @param hp_data The hyper-parameter search grid.
  #' @param scoring_data \code{hp_data} with model performance scoring up to the current iteration. This will be one of \code{genre_performance} or \code{book_performance} in the global environment.
  #' @param candidate_hps One of the sets of hyper-parameters contained in `hp_data`. This will be the current iterative state of global object \code{hyperparams.iter} saved into object \code{hyperparams}.
  #' @param score_expr An un-evaluated expression that, when evaluated, returns a logical vector based on features in object \code{scoring_data} (for example, \code{rlang::expr(score >= 0.8)}).
  #' @param score_state The index or name of the state of the result of calling \code{score_fun} to use as the basis for hyper-parameter comparison. This is passed on to function \code{\link{bayes}}.
  #' 
  #' @return A logical scalar indicating whether or not to pass/reject the candidate hyper-parameter set based on the likelihood of improving scoring
  #' 
  #' @family Bayesian helpers
  assertive::assert_all_are_true(c(
    # Required libraries:
    require(data.table)
    , require(purrr)
    ))
  
  force(scoring_data);
  
  hp_data <- purrr::keep(hp_data, \(x) data.table::uniqueN(x) > 1);
  hp_data <- hp_data[scoring_data, on = names(hp_data)]
  #[, mget(c("score", names(hp_data))) ];
  hp_data[, score := as.numeric(score)];
  hp_data[, score.test := eval(rlang::enexpr(score_expr))];
  
  # `hp_names` ensures uniformity of hyper-parameter names being chosen across runs:
  hp_names <- grep("exp|depth|drop|l2", names(hp_data), value = TRUE);
    
  melt(hp_data[1:nrow(scoring_data)], id.vars = c("score", "score.test"), variable.factor = FALSE) |>
    list2env(envir = environment());
  
  if (.debug || any(score == 0)) browser()
  # score.test <- score_fun(score);
  
  L <- table(paste(variable, value, sep = "="), score.test)
  score.test <- unique(score.test)
  
  # browser()
  L <- magrittr::set_attr(L * (1/rowSums(L)), "dimnames", list(rownames(L), score.test))
  
  H <- table(paste(variable, value, sep = "=")) |> 
    softmax() |> 
    as.vector() |>
    rlang::set_names(rownames(L))
  
  # Calculate the Bayesian stats:
  hyper_bayes <- rlang::list2(!!!mget(c("H", "L")), !!! bayes(H, L)) |>
    purrr::map(purrr::modify_if, is.nan, ~0)
  
  # Capture the odds-ratios:
  hb_odds <- hyper_bayes$posterior_odds;
  
  # Retrieve the current hyper-parameter values before modeling:
  cur_hp <- hyperparams[hp_names] %$% { paste(names(.), ., sep = "=") }
  
  # Return the result of a simple test where `TRUE` allows a new 
  # model to be fit under the proposed hyper-parameters and `FALSE` 
  # causes the hyper-parameter iterator to advance:
  if (score_state %in% colnames(hyper_bayes$posterior_odds)){
    # If all values in `cur_hp` have been seen used in any combination, 
    # check `cur_hp` against historical Bayesian scoring. `cur_hp`.
    # Return whether any of the values in `hb_check` are 
    # greater than some threshold. 
    # `hb_check` contains odds making values >= 1 increasing the odds of 
    # success; however, a threshold of 0.95 serves as a safeguard on making 
    # too strict of an evaluation given the stochastic nature of fitting a model:
    
    hb_check <- hyper_bayes$posterior_odds[, score_state][cur_hp]
    prod(hb_check, na.rm = TRUE) |>
      (\(k) list(score = scoring_data[, score[.N]], val = k, result = k >= 0.95))()
  } else {
    # Target state not found in current scoring results:
    list(score = scoring_data[, score[.N]], val = -1, result = FALSE)
  }
}
