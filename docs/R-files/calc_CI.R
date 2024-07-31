calc.CI <- function(i, label, ci = 0.95){
  #' Calculate Confidence Intervals
  #' 
  #' \code{calc.CI} is a wrapper for \code{\link[Rmisc]{CI}}
  #' 
  #' @param i A vector of numeric values
  #' @param label (string) A label that will name the output
  #' @param ci (numeric | 0.95) The confidence level to use in calculating the confidence interval
  #' 
  #' @return A \code{\link[data.table]{data.table}} object with confidence interval data
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(data.table)
    , require(purrr)
    , require(magrittr)
    ))
  
  if (missing(label)){ 
    label <- "values" 
  } else { 
    label <- as.character(label)[1] 
  }
  
  as.list(Rmisc::CI(i, ci = ci)) %>% { 
    data.table::data.table(
      metric.label = label
      , mean = .$mean
      , `+/-` = .$upper - .$mean
      , valid = ifelse(
          is.nan(.$lower)|is.na(.$lower)
          , FALSE
          , (.$mean - .$lower) >= 0
          )
      )[
      , c("+/-", "valid") := .SD[, .(`+/-`, valid)] |>
          purrr::imap(\(x, y){
            purrr::modify_if(
              .x = x
              , .p = \(i) is.na(i)|is.nan(i)
              , .f = \(...) list(`+/-` = 0, valid = FALSE)[[y]]
              )
          })
      ]
  }
}
