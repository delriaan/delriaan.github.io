get_model_run <- \(..., root_dir = "model_runs", save_dir = "saved_data/models", log_dir = "model_logs"){
  #' Model Run Label Maker
  #' 
  #' @param ... A list of labels to use for the model run
  #' @param root_dir The path under which model runs will be saved
  #' 
  #' @return A named list of labels indicating the current run in \code{"%Y%m%d_%H%M"} format, \emph{model logging} path, and \emph{model save} path (different from the path used for \code{tensorflow} callbacks).
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(data.table)
    , require(stringi)
    ))
  
  user_labels <- if (...length() == 0){
    NULL 
  } else {
    rlang::enexprs(...) |> as.character() |> paste(collapse = "_");
  }
  
  cr <- file.path(root_dir, paste(c(user_labels, format(Sys.time(), "%Y%m%d_%H%M")), collapse = "_")) 
  
  cr_log <- stringi::stri_split_fixed(cr, "/", simplify = TRUE) |> 
    as.vector() |>
    data.table::last() |> 
    sprintf(fmt = file.path(log_dir, "%s"));
  
  cr_save <- stringi::stri_split_fixed(cr, "/", simplify = TRUE) |> 
    as.vector() |>
    data.table::last() |> 
    sprintf(fmt = file.path(save_dir, "%s"));
  
  mget(ls(pattern = "^cr"))
}