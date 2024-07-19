make_target_classes <- \(..., label.ordered = FALSE){
  #' Make Target Classes
  #' 
  #' @param ... \code{\link[rlang]{dots_list}} One or more sets of vectors containing repeating levels from which classes labels are to be created. 
  #' @param label.ordered (logical) If \code{TRUE}, the output is ordered by \code{sort(names())}
  #' 
  #' @return For each element in the input, a named vector of unique values with attribute \code{"probs"} indicating the naive probability of occurrence. If the inputs were provided as named arguments, the output will preserve the names.
  #' 
  #' @examples
  #' make_target_classes(sample(LETTERS[c(1, 3, 5, 7)], 50, TRUE), sample(c(1, 3, 5, 7), 50))
  #' make_target_classes(sample(LETTERS[c(1, 3, 5, 7)], 50, TRUE), sample(c(1, 3, 5, 7), 50, label.ordered = TRUE))
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(magrittr)
    , require(book.of.utilities)
    ))
  
  res <- rlang::list2(...);
  fun <- \(i){
    out <- table(i)
    out |>
      book.of.utilities::ratio(dec = 6) |> 
      (\(x){
        if (label.ordered){
          x <- x[sort(names(x))]
        }
        magrittr::set_attr(rlang::set_names(names(x)), "probs", x)
      })();
  }
  
  if (length(res) > 1){ lapply(res, fun) } else { fun(res[[1]]) }
}
