f_split <- function(x, f, ...){
  #' Formula-based Split
  #' 
  #' \code{f_split} is a wrapper base::split() and data.table:::split.data.table() supporting a formulaic definition of the splitting factors.
  #' 
  #' @param x,... See \code{?split}
  #' @param f See \code{?split}: may also be a right-sided formula (e.g., \code{~var1 + var2 + ...})
  #' 
  #' @return See \code{?split}. The original class is returned for each element if possible.
  #' 
  #' @examples
  #' f_split(mtcars, ~cyl) |> map(class)
  #' f_split(as.matrix(mtcars), ~cyl) |> map(class)
  #' f_split(mtcars, f = mtcars["cyl"])
  
  orig_class <- class(x)[1]

  # if (orig_class %in% c("matrix", "array", "table")){
  #   x <- data.table::as.data.table(x, keep.rownames = TRUE)
  # }
  
  if (is_formula(f)){ 
    f <- terms(f, data = data.table::as.data.table(x, keep.rownames = TRUE)) |> attr("term.labels") 
  }
  
  if (is.data.table(x)){
    split(x, by = f, ...) 
  } else if (orig_class %in% c("matrix", "array", "table")){
    split_vec <- x[, f] |> (\(x) match(x, x))()
    
    split_vec[!duplicated(split_vec)] |>
      rlang::set_names(x[!duplicated(split_vec), f]) |>
      lapply(\(i, ...) x[which(split_vec == i), , drop = FALSE])
  } else { 
    split(x, f = f, ...)
  }
}


