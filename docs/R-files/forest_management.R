forest.mgmt <- function(i, ..., auto.install = FALSE){
  #' Calculate Anomaly Scores via isofor
  #' 
  #' \code{forest.mgmt} takes a numeric input and returns a predicted anomaly score via \code{\link[isofor]{iForest}}.
  #' 
  #' @param i The input 
  #' @param ... Additional arguments sent to \code{\link[isofor]{iForest}}
  #' @param auto.install (logical) Should the library be downloaded and installed if not installed?
  #' 
  #' @return A vector of predictions \eqn{ 0 <= n <= 1} of the same length as the input (or rows if tabular)
  #' @references https://github.com/gravesee/isofor
  
  assertive::assert_is_logical(auto.install)

  if (!"isofor" %in% rownames(installed.packages())){
    if (auto.install){
      remotes::install_github("gravesee/isofor")
    } else {
      cli::cli_abort("Package `isofor` not installed. Please re-run with `auto.install=TRUE` or after manually installing.")
    }
  }

  .iforest = vector(mode = "list", length = 3L);
  .iforest$data = i;
  .iforest$tree = isofor::iForest(.iforest$data, ...);
  .iforest$predict = predict(.iforest$tree, newdata = .iforest$data);
  .iforest;
}
# ?forest.mgmt