modify_iter <- function(it){
  #' Modify an Iterator
  #' 
  #' \code{modify_iter}() augments objects created via the \code{iterators} library with the following functions:\cr
  #' \describe{
  #' \item{reset}{Resets the internal counter}
  #' \item{value}{Returns the current value of property \code{obj} in a list}
  #' \item{set}{Sets the internal counter}
  #' \item{add}{Adds to the object being iterated and adjusts property \code{length}}
  #' \item{peek}{Similar to \code{value()} but is returns a scalar}
  #' }
  #' 
  #' @return A modified version of the input
  #' 
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(iterators)
    , require(magrittr)
    , require(purrr)
    # Class validation:
    , is(it, "iter")
    ))
  
  it$reset <- \(){ 
    it$state %$% { i <- 0 }
  }
  
  it$value <- \(){
    it$state %$% { 
      if (i > 0){ obj[i] } else { NA } 
    }
  }
  
  it$set <- \(i){ 
    if (is.numeric(i)){
      i <- as.integer(i)
    }
    assertive::assert_is_integer(i)
    assign("i", i, envir = it$state)
  }
  
  it$peek <- \(i){ 
    if (is.numeric(i)){
      i <- as.integer(i)
    }
    assertive::assert_is_integer(i)
    return(it$state$obj[[i]] )
  }

  it$add <- \(...){
    tmp <- rlang::list2(!!!it$state[["obj"]], ...)
    assign("obj", tmp, envir = it$state);
    it$length <- length(tmp)
  }
  
  return(it);
}
