# <snippet: progress bar format> ----
  read.snippet(action = parse, doc = NULL, progress, bar, format);
  pb_format <- "{cli::pb_spin} Processing text ({cli::pb_percent} | {cli::pb_elapsed} (ETA: {cli::pb_eta}))"
# </snippet>
#
# <snippet: open docx> ----
  read.snippet(action = parse, doc = NULL, open, docx);
  local({
    document_path <- ""
    paste(
      "start"
      , glue::glue("/D {shQuote(file.path(getwd(), ''))}")
      , shQuote(Sys.getenv("WORD_EXE"))
      , shQuote(document_path)
      )
    })
# </snippet>
#
# <snippet: protect sensitive :: Protect sensitive information> ----
  read.snippet(action = parse, doc = NULL, protect, sensitive);

  protect <- \(data, ..., method = c("omit", "mask", "obfuscate")){
    #' Project Sensitive Information
    #' 
    #' @param data The input dataset with fields to protect (coerced to a )
    #' @param ... \code{\link[rlang]{dots_list}} Names or symbols of columns to obfuscate or remove
    #' @param method (string) One of "omit", "mask", or "obfuscate"
    #' 
    protected <- rlang::enexprs(...) |> as.character()
    method <- match.arg(arg = method)
    switch(
      method
      , mask = purrr::modify_at(data, protected, \(x) rep.int("#masked#", length(x)))
      , omit = purrr::discard_at(data, protected)
      , obfuscate = purrr::modify_at(data, protected, \(x){ 
            res <- sample(length(unique(x)) * 10, length(unique(x)))[match(x, unique(x))]
            magrittr::set_attr(res, "label", "obfuscated")
          })
      , data
      )
    }
# </snippet>
#
