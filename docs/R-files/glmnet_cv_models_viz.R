glmnet_cva_viz <- \(cva_obj, name, ...){
  viz_data <- cva_obj %$% purrr::map2(modlist, alpha, \(x, a){
    list(
      alpha = a
      , min_lambda = x$lambda.min
      , score = weighted.mean(x$cvm, 1/x$cvsd)
      , cvm_min = min(x$cvm)
      , cvm_sd = x$cvm |> sd()
      )
    }) |>
    data.table::rbindlist(idcol = "model_id")
  
  if (missing(name)){ name <- glue::glue("Model ID: {viz_data$model_id}") }
  
  best_mdl <- which.max(viz_data$score)

  mdl_viz <- plotly::plot_ly(
    data = viz_data
    , x = ~min_lambda
    , y = ~alpha
    , color = ~score
    , marker = ~list(size = 150 * book.of.utilities::ratio(1/cvm_sd), line = list(color = I("#333")))
    , name = name
    , hovertext = ~sprintf(paste(
          "<b>Model ID:</b>: %s"
          , "<b>Alpha</b>: %.4f"
          , "<b>Min. Lambda</b>: %.4f"
          , "<b>Std.Dev CV-Mean</b>: %.4f"
          , sep = "<br>"
          )
        , model_id, alpha, min_lambda, cvm_sd
        )
    , type = "scatter"
    , mode = "markers"
    , ...
    ) |>
    plotly::config(mathjax = "cdn") |>
    plotly::colorbar(title = htmltools::HTML("<span style='font-family:Cambria;'>CV-Mean / &#963;</span>")) |>
    plotly::layout(
      title = plotly::TeX(glue::glue("\\text{{CVA Models :: {name} (best = #{best_mdl}): }}\\alpha \\text{{ vs. }} score"))
      , xaxis = list(title = list(text = plotly::TeX("\\bar{\\text{CV}}_\\text{min}")))
      , yaxis = list(title = list(text = plotly::TeX("\\alpha")))
      , margin = list(t = -5, b = -5)
      )
  
  mget(c("best_mdl", "mdl_viz"))
}
