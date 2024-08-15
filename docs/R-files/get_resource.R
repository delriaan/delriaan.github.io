get_resource <- (\(){
  #' Get an R Script
  #'
  #' @param url The URL of the hosted R script. The \emph{.R} extension is optional and will be appended automatically.
  #'
  #' @return an unevaluated expression containing the contents of the matched file (exact match excluding the file extension).
  f <- \(url, root = "https://delriaan.github.io/R-files"){
      url <- rlang::enexpr(url) |> as.character()
      url <- glue::glue("{root}/{url}{if (!grepl(\"[.]R$\", url)) \".R\"}")
      req <- httr2::request(url)
      httr2::req_perform(req) |>
        httr2::resp_body_string() |>
        sprintf(fmt = "{%s}") |>
        str2lang()
    }

  purrr::possibly(purrr::slowly(f, rate = purrr::rate_delay(1)), otherwise = NULL)
})()
