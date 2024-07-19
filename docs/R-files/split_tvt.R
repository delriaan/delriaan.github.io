assertive::assert_all_are_true(c(
  # Required Libraries:
  require(data.table)
  , require(plotly)
  , require(architect)
  , require(book.of.utilities)
  ))
split_tvt <- \(n, train = 0.8, val = 0.1, random = TRUE){
  #' Train/Validation/Test Splitter
  #' 
  #' @section Argument \code{n}:
  #' If \code{n} is 1, then the function returns \bold{train}.\cr
  #' If \code{n} is 2, then the function returns \bold{train} and \bold{test}.\cr
  #' If \code{n} is greater than 2, then the function returns \bold{train}, \bold{test}, and \bold{validation}, randomly assigned along a vector of length \code{n}.
  #' 
  #' @param n The number of object types to return
  #' @param train The proportion of objects to assign to the training set
  #' @param val The proportion of objects to assign to the validation set
  #' @param random Whether to randomly assign the objects to the sets
  #' 
  #' @return A vector of length \code{n} having values indicating \bold{train}, \bold{validation}, and\bold{test} indices.
  #' 
  if (n == 1){
    return("train")
  } else if (n == 2){
    return(c("train", "test"))
  } else {
    res <- c("train", "val", "test")
  }
  
  f <- if (random){ 
    sample(c(1:3), n, replace = TRUE, prob = c(train, val, 1 - train - val))
  } else {
    rep.int(1, floor(n * train)) |>
      c(rep.int(2, floor(n * val))) %>%
      c(rep.int(3, n - length(.)))
  }
  
  res[f]
}
split_tvt_balanced_class <- \(sample_id, class_nm
  , class_prop = rlang::set_names(1/length(class_nm), class_nm)
  , train = 0.7
  , val = (1 - train) /2
  ){
  #' Balanced Class \code{split_tvt}
  #' 
  #' \code{split_tvt_balanced_class} is a wrapper for \code{\link{split_tvt}} and provides balanced class splits across train, validation, and test slices.
  #' 
  #' @details
  #' \enumerate{
  #' \item{The ratio between observed and naive (i.e., equal) class proportionality are compared.}
  #' \item{Train and validation proportions provided by the user are re-scaled based on the inverse relationship with the result of the prior step.}
  #' \item{The result is train/val/test assignment across classes being adjusted to be more or less represented based on the degree of over/under-representation (indicated by step #1).}
  #' }
  #' 
  #' @param sample_id (integer) Sample indices
  #' @param class_nm (string) The name of the class
  #' @param class_prop (numeric[]) A named vector of global class proportions: Defaults to \eqn{n^{-1}}
  #' @param train,val (numeric) Proportions for training and validation sets: \code{val} defaults to \eqn{\frac{(1 - train)}{2}}.
  #' 
  #' @return A \code{\link[data.table]{data.table}} object consisting of the record index and the TVT label.
  n_classes <- length(class_prop);
  n <- length(sample_id);
  
  expected <- 1/n_classes;
  actual <- class_prop[class_nm];
  scaling_factor <- as.vector(actual/expected);
  
  spsUtil::quiet(data.table::data.table(
    doc_idx = sample_id
    , tvt = split_tvt(
              n =  n
              , train = train
              , val = val * (book.of.utilities::odds2probs(1/scaling_factor)[[1]])
              )
    ));
}
viz_class_splits <- \(X, class_col = "class", tvt_col = "tvt"){
  #' Visualize Class vs. TVT Splits
  #' 
  #' @param X The input data.frame or similar
  #' @param class_col,tvt_col (string,symbol) The names of the columns holding the class and tvt-split values, respectively
  #' 
  #' @return Invisibly, the output from \code{\link[plotly]{plotly_data}}
  
  # :: Force `X` to have pre-defined names:
  X <- as.data.table(X) |>
    data.table::copy() |>
      data.table::setnames(
        rlang::enexprs(class_col, tvt_col) |> as.character()
        , c("class_col", "tvt_col")
        );
  
  z <- architect::define(
      X
      , .(P = .N) ~ class_col + tvt_col
      , P = book.of.utilities::ratio(P, dec = 6)
      , keep.rownames = FALSE
      );
    
  ex_class <- architect::define(
      X
      , .(ex_class_P = .N) ~ class_col
      , ex_class_P = book.of.utilities::ratio(ex_class_P, dec = 6)
      , keep.rownames = FALSE
      );
  
  ex_tvt <- architect::define(
      X
      , .(ex_tvt_P = .N) ~ tvt_col
      , ex_tvt_P = book.of.utilities::ratio(ex_tvt_P, dec = 6)
      , keep.rownames = FALSE
      );
  
  viz <- plotly::plot_ly(
    data = z[ex_class, on = "class_col"][ex_tvt, on = "tvt_col"]
    , z = ~P/max(P)
    , x = ~tvt_col
    , y = ~class_col
    , hoverinfo = "x+y+text"
    , text = ~sprintf(
        fmt = "<b>Z</b>: %.2f<br>Of <b>%s</b>: %.2f%%<br>Of <b>%s</b>: %.2f%%"
        , (\(p_p, p_c){ (p_p/p_c) })(ex_class_P, P)
        , tvt_col
        , 100 * P / ex_tvt_P
        , class_col
        , 100 * P / ex_class_P
        )
    , type = "heatmap"
    ) |> 
    plotly::colorbar(title = list(text = "Intensity")) |>
    plotly::layout(
      title = "Class Proportion by Train/Val/Test Split"
      , xaxis = list(title = "Train/Val/Test")
      , yaxis = list(title = "Class")
      , margin = list(t = -5, b = -5)
      )
  print(viz)

  return(invisible(plotly::plotly_data(viz)))
}
