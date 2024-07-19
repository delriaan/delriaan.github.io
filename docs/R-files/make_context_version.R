make_context_version <- \(context, ..., prefix = "tag_"){
  #' Make Context Version
  #' 
  #' The use case for this function is to provide a formatted timestamp by which 
  #' objects can be tagged as a form of version tracking.
  #' 
  #' @param context The context for the version (e.g., \code{'model'}, \code{'data'}, etc.). Only the first value provided will be used.
  #' @param ... (Not used)
  #' @param prefix The prefix for the tag (default: \code{'tag_'})
  #' 
  #' @return A formatted timestamp
  context <- rlang::enexprs(context) |> as.character();
  # browser()
  if (is.call(str2lang(context)) || !grepl("model|data", context)){
    stop("Invalid context. Please use one of 'model' or 'data' as the context. Argument values may be unquoted")
  }
  format(Sys.time(), paste(prefix, context, "%Y%m%d%H%M%S", sep = "_"))
}
