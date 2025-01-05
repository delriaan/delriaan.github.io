hyper_bayesian <- \(hp_data, scoring_data, candidate_hps, score_expr, score_state, ..., .debug = FALSE){
  #' Bayesian Hyper-parameter Search
  #' 
  #' @param hp_data The hyper-parameter search grid.
  #' @param scoring_data \code{hp_data} with model performance scoring up to the current iteration. This will be one of \code{genre_performance} or \code{book_performance} in the global environment.
  #' @param candidate_hps One of the sets of hyper-parameters contained in `hp_data`. This will be the current iterative state of global object \code{hyperparams.iter} saved into object \code{hyperparams}.
  #' @param score_expr An un-evaluated expression that, when evaluated, returns a logical vector based on features in object \code{scoring_data} (for example, \code{rlang::expr(score >= 0.8)}).
  #' @param score_state The index or name of the state of the result of calling \code{score_fun} to use as the basis for hyper-parameter comparison. This is passed on to function \code{\link{bayes}}.
  #' @param ... (\code{\link[rlang]{dots_list}}) Additional names or patterns of features to append to the base pattern of \code{"exp|depth|drop|l2"}.
  #' @return A logical scalar indicating whether or not to pass/reject the candidate hyper-parameter set based on the likelihood of improving scoring
  #' 
  #' @note \code{nrow(hp_data) >= nrow(scoring_data)}
  #' 
  #' @family Bayesian helpers
  assertive::assert_all_are_true(c(
    # Required libraries:
    require(data.table)
    , require(purrr)
    # Dimensionality check:
    , nrow(hp_data) >= nrow(scoring_data)
    ))
  
  force(scoring_data);
  
  # :: Remove features that only have one unique value:
  hp_data <- purrr::keep(hp_data, \(x) data.table::uniqueN(x) > 1);

  # :: Merge scoring data to the hyperparameter data to provide a dataset
  # comprised of historical successes/failures and associated hyperparameters used.
  hp_data <- hp_data[scoring_data, on = names(hp_data)]
  #[, mget(c("score", names(hp_data))) ];
  hp_data[, score := as.numeric(score)];

  # :: Add a feature to capture the output of the scoring test provided in `score_expr`: 
  hp_data[, score.test := eval(rlang::enexpr(score_expr))];
  
  # `hp_names` ensures uniformity of hyper-parameter names being chosen across runs:
  hp_names <- grep(paste(c("exp|depth|drop|l2", ...), collapse = "|"), names(hp_data), value = TRUE);
    
  # :: "Melt" (wide-to-long) `hp_data` and use this to create objects 
  # 'score', 'score.test', 'hp_variable', and 'hp_value' 
  # in the local environment via `list2env`:
  hp_data[1:nrow(scoring_data)] |>
    melt(
      id.vars = c("score", "score.test")
      , variable.factor = FALSE
      , variable.name = "hp_variable"
      , value.name = "hp_value"
      ) |>
    list2env(envir = environment());
  
  if (.debug || any(score == 0)) browser()
  # score.test <- score_fun(score);
  
  # :: Likelihood (iteratively accumulated over the hyperparameter search space):
  L <- table(paste(hp_variable, hp_value, sep = "="), score.test)
  score.test <- unique(score.test)
  
  L <- (L * (1/rowSums(L))) |>
    magrittr::set_attr("dimnames", list(rownames(L), score.test))
  
  # :: Hypothesis/Candidate (the current hyperparameter set):
  H <- table(paste(variable, value, sep = "=")) |> 
    softmax(decimals = 12, as_array = TRUE)
  
  # :: Calculate the Bayesian stats (see ?bayes):
  hyper_bayes <- {
    rlang::list2(!!!mget(c("H", "L")), !!!bayes(H, L)) |>
    purrr::map(purrr::modify_if, is.nan, ~0)
  }
  
  dimnames(hyper_bayes$posterior_odds) <- dimnames(L)
  hp_odds <- hyper_bayes$posterior_odds
  
  # :: Retrieve the current hyper-parameter values before modeling:
  cur_hp <- hyperparams[hp_names] %$% { paste(names(.), ., sep = "=") }
  
  # :: Return the result of a simple test where `TRUE` allows a new 
  # model to be fit under the proposed hyper-parameters and `FALSE` 
  # causes the hyper-parameter iterator to advance:
  if (score_state %in% colnames(hp_odds)){
    # If all values in `cur_hp` have been used in any combination, 
    # check `cur_hp` against historical Bayesian scoring.
    # Return whether any of the values in `hb_check` are greater than some threshold. 
    #
    # `hb_check` is a vector of odds-ratios making values > 1 increasing the odds of 
    # success; however, a threshold of 0.95 serves as a safeguard on making 
    # too strict of an evaluation given the stochastic nature of fitting a model:
    
    hb_check <- hp_odds[cur_hp, score_state]

    # Take the product of the vector of odds-ratios to reflect the odds of 
    # independent likelihoods occurring simultaneously (multiplication rule):
    prod(hb_check, na.rm = TRUE) |>
      (\(k) list(score = scoring_data[, score[.N]], val = k, result = k >= 0.95))()
  } else {
    # Target state not found in current scoring results:
    list(score = scoring_data[, score[.N]], val = -1, result = FALSE)
  }
}
