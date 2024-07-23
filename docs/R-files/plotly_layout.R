plotly_layout <- function(p, ...){
  #' Plotly Layout Helper
  #' @param p, ... (see \code{\link[plotly]{layouy}})
  #'
  #' \code{plotly_layout} allows a user to pass saved options for \code{\link[plotly]{layout}}.
  #'
  #' @return See \code{\link[plotly]{layout}}
  dflt_args <- list(
    p = p
    , plot_bgcolor = "#AAA"
    , paper_bgcolor = "#777"
    , xaxis = list(gridcolor = "#DEDEDE")
    , yaxis = list(gridcolor = "#DEDEDE")
    );

  usr_args <- list(
    update = rlang::list2(...) %>% purrr::keep_at(c("plot_bgcolor", "paper_bgcolor")) |> purrr::flatten()
    , merge = rlang::list2(...) %>% purrr::discard_at(c("plot_bgcolor", "paper_bgcolor"))
  )

  args <- purrr::list_modify(dflt_args, !!!usr_args$update) |> purrr::list_merge(!!!usr_args$merge)

  do.call(plotly::layout, args)
}
