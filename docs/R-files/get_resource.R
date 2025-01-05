get_rscript <- \(..., resolve = TRUE, root = "https://delriaan.github.io/R-files"){
  #' Get an R Script
  #'
  #' @param ... The file name(s) of the hosted R script(s). The \emph{.R} extension is optional and will be appended automatically.
  #' @param resolve (logical) Evaluates the parsed expression in the calling environment when \code{TRUE}
  #' @param root The root URL of the endpoint
  #'
  #' @return \cr \itemize{
  #' \item{\code{resolve = TRUE}: A list of strings indicating the file and URL sourced.}
  #' \item{\code{resolve = FALSE}: A list of expressions created from retrieved files, each provided with a 'comment' attribute of the file and URL used.}
  #' }
  #'
  #' @note Data pulls from R source files located at \url{https://delriaan.github.io/R-files}
  #'
  #' @export
  
    files <- rlang::enexprs(...) |> as.character()
    # env <- rlang::caller_env()
  
    url_string <- glue::glue("{root}/{gsub(files, pattern = '[.]R', replacement = '') |> unlist()}.R") |>
      rlang::set_names(files)

    f <- purrr::slowly(\(u, f){
        if (!resolve){
          req <- rvest::read_html(u) |> 
            rvest::html_element(xpath = "//body")|> 
            rvest::html_text() |>
            sprintf(fmt = "{%s}") |>
            str2lang()        
          comment(req) <- glue::glue("{f}: {u}")
          return(req)
        } else {
          source(u)
          return(glue::glue("{f}: {u}"))
        }
      }, rate = purrr::rate_delay(1))
    # browser()
    
    purrr::imap(url_string, purrr::possibly(f, otherwise = NULL))
    # if (resolve){ spsUtil::quiet(purrr::walk(res, eval, envir = env)) }
    # invisible(res)
}

get_resource <- get_rscript