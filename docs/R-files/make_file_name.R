make_file_name <- \(title = '', ..., extn = "html"){
  #' Make a File Name
  #' 
  #' @param title (string) The title to give the output
  #' @param ... \code{\link[rlang]{dots_list}} strings or valid names used to create the file path in the order given.
  #' @param extn (string) The extension(s) to append to the file ('.' not necessary)
  #' 
  #' @return A vector of file paths ending with the file name and extension
  #' 
  .title <- glue::glue(title, .envir = rlang::caller_env())
  .path <- rlang::expr(glue::glue(file.path(!!!as.character(rlang::enexprs(...))), extn, .envir = rlang::caller_env(), .sep = ".")) |> eval()
  rlang::set_names(.path, title)
}
