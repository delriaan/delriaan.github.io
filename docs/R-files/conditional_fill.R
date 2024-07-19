conditional_fill <- \(x, along = NULL, cond = is.na){
  #' Conditional Fill
  #' 
  #' This function will fill in missing values in a vector based on a condition. 
  #' The replacement values are the last value for which the condition is \code{FALSE}.
  #' 
  #' @param x A vector
  #' @param along A vector of the same length as \code{x} that is used to index \code{x}
  #' @param cond A vectorized function returning a logical vector
  #' 
  #' @return The input vector with the conditional fill applied
  row_idx <- seq_along(x)
  na_idx <- which(cond(x))
  
  if (rlang::is_empty(along)){ along <- x }
  
  val <- along[1];
  
  for (i in row_idx){
    if (cond(x[i])){ x[i] <- val } else { val <- along[i] }
  }
  
  return(x)
}
