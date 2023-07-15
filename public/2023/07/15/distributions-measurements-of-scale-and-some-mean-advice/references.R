library(htmltools)
library(magrittr)
library(book.of.utilities)

# :: References ----
references <- p(
  tags$h1(style = "font-weight:bold", "References")
  , tags$ul(list(
      tags$a(
        href = "https://statisticsbyjim.com/basics/nominal-ordinal-interval-ratio-scales/"
        , target = "_blank"
        , "Nominal, Ordinal, Interval, and Ratio Scales (Statistics by Jim)"
        )
    , tags$a(
        href = "https://byjus.com/maths/scales-of-measurement/"
        , target = "_blank"
        , "Scales of Measurement (Byju's Learning)"
        )
    , tags$a(
        href = "https://en.wikipedia.org/wiki/Level_of_measurement#"
        , target = "_blank"
        , "Level of Measurement (Wikipedia)"
        )
    , tags$a(
        href = "https://365datascience.com/tutorials/statistics-tutorials/distribution-in-statistics/"
        , target = "_blank"
        , "What is a Distribution in Statistics? (365 Data Science)"
        )
    ) |> purrr::map(tags$li)
  )
)

# :: Predefined Visualizations ----
X <- 0:24
X.bin <- bin.windows(X+1, use.bin = 5, as.factor = TRUE, label_format = "%s to %s") 
X2.bin <- bin.windows(X - 0.5*max(X), use.bin = 5, as.factor = TRUE, label_format = "%s to %s") 

#
tags$table(
  tags$tr(
    tags$th(align="center", style="width:120px; ", "Distance (mi)")
    , tags$th(align="center", style="width:90px; ", "# Stops")
    , tags$th(align="center", style="width:120px; ", "% Proportion" |> HTML())
    )
  , table(X.bin) |> 
      as.list() |> 
      purrr::imap(\(x, y){ 
        tags$tr(
          tags$td(align="center", y)
          , tags$td(align="center", x)
          , tags$td(align="center", {
              i <- table(X.bin)
              j <- book.of.utilities::ratio(i, type = "of.sum", decimals = 5) %>% .[[y]];
              k <- (\(x) x * (1-x))(book.of.utilities::ratio(i, type = "pareto", decimals = 5) %>% .[[y]]);
              sprintf("%.2f", j * 100) |> HTML()
            })
        )
    })
  ) |> 
html_print()

#
dist_plot_freq <- { 
  table(X.bin)[X.bin] |> 
    data.table::as.data.table(keep.rownames = TRUE) |>
    data.table::setnames(c("dist", "freq")) |>
    unique() |>
    modify_at("dist", \(x) factor(x, levels = x[!duplicated(x)], ordered = TRUE)) |> 
    plotly::plot_ly(x = ~dist, y = ~freq, type = "bar") |>
    plotly::layout(
      title = ""
      , xaxis = list(title = "Distance Band")
      , yaxis = list(title = "Frequency")
      , margin = list(b = -10, t = 12)
      )
}

#
dist_plot_prop <- {
  table(X.bin)[X.bin] |> 
    book.of.utilities::ratio(type = "pareto", decimals = 10) |> 
    (\(x) x * (1-x))() |> 
    data.table::as.data.table(keep.rownames = TRUE) |>
    data.table::setnames(c("dist", "prop")) |>
    modify_at("dist", \(x) factor(x, levels = x[!duplicated(x)], ordered = TRUE)) %>% {
      .[, .(prop = max(prop)), by = dist]
    } |> 
    plotly::plot_ly(x = ~dist, y = ~prop, type = "bar") |>
    plotly::layout(
      title = ""
      , xaxis = list(title = "Distance Band")
      , yaxis = list(title = "Cumulative Proportion")
      , margin = list(b = -10, t = 12)
      )
}
