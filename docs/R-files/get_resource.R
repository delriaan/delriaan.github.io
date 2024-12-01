get_resource <- \(..., resolve = FALSE, root = "https://delriaan.github.io/R-files"){
  #' Get an R Script
  #'
  #' @param ... The file name(s) of the hosted R script(s). The \emph{.R} extension is optional and will be appended automatically.
  #' @param resolve (logical) Evaluates the parsed expression in the calling environment when \code{TRUE}
  #' @param root The root URL of the endpoint
  #'
  #' @return A list of expressions created from retrieved files.
  #'
  #' @note Data pulls from R source files located at \url{https://delriaan.github.io/R-files}
  #'
  #' @export
  
    files <- rlang::enexprs(...) |> as.character()
    url_string <- glue::glue("{root}/{files}{if (!grepl(\"[.]R$\", files)) \".R\"}") |>
      rlang::set_names(files)

    f <- purrr::slowly(\(u, f){
        req <- rvest::read_html(u) |> 
          rvest::html_element(xpath = "//body")|> 
          rvest::html_text() |>
          sprintf(fmt = "{%s}") |>
          str2lang()
      
        comment(req) <- glue::glue("{f}: {u}")    
        return(req)
      }, rate = purrr::rate_delay(1))

    res <- purrr::imap(url_string, purrr::possibly(f, otherwise = NULL))
    if (resolve){ spsUtil::quiet(purrr::walk(res, eval, envir = rlang::caller_env())) }
    invisible(res)
}
