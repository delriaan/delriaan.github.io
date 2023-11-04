# GLOBAL OBJECTS ----

def_of <- \(x){ GET(url = sprintf(getOption("dictionaryAPI"), x)) |> content() }

.string <- stri_extract_all_words("I tried to climb the hill but was too tired", simplify = TRUE) |> 
  rlang::set_names();

dimnames(.string) <- list(NULL, unlist(.string));

attr(.string, "sentence") <- paste(.string, collapse = " ") |> paste0(".")

ex_data <- sample(100, 10);

ordinal <- seq_along(ex_data);

interval <- round(ex_data - mean(ex_data), 2);

ex_data.html <- tags$span(sprintf("[%s]", paste(ex_data, collapse = ", ")));

ordinal.html <- tags$span(sprintf("[%s]", paste(ordinal, collapse = ", ")));

interval.html<- tags$span(sprintf("[%s]", paste(interval, collapse = ", ")));

fun <- \(j){
  rgb.vec <- c("black"
               , rgb(red = (1 - as.numeric(j[-1])) |> modify_if(\(x) x > 0.75, \(x) 0.75)
                     , green = (1 - sqrt(as.numeric(j[-1]) * 0.85)) |> modify_if(\(x) x > 0.75, \(x) 0.75)
                     , blue = (1 - as.numeric(j[-1])/max(as.numeric(j[-1]))) |> modify_if(\(x) x > 0.75, \(x) 0.75)
               ))
  
  imap(rgb.vec, \(x, y){
    tags$td(
      style = paste(
        ifelse(y == 1, "font-weight:bold; width:100px; text-align: right", "text-align: center")
        , glue::glue("color: {x}")
        , sep = "; "
      )
      , j[y]
    )
  }) |> 
    tags$tr()
}

.string_sim <- .string |> 
  stringsimmatrix(method = "jw", useNames = TRUE) |> 
  as.matrix() |> 
  round(4);

.string_sim.viz <- data.table::as.data.table(.string_sim, keep.rownames = TRUE) |>
  (\(i){
    rlang::inject(tags$table(
      style = "margin-left:25px; font-size:smaller; "
      , stri_replace_first_fixed(names(i), "rn", "") |>
        imap(\(x, y){ tags$th(
          style = ifelse(y == 1, "font-weight:bold; width:100px; text-align: right", "text-align: center")
          , x)
        }) |> 
        tags$tr()
      , !!!apply(i, 1, fun, simplify = FALSE)
    ))
  })();

ratio.data <- list()
ratio.data$entrance <- c(LETTERS[1:4])
ratio.data$entered <- book.of.utilities::factor.int(96) |> sample(4)
ratio.data$exited <- sample(max(ratio.data$entered), 4)
ratio.data$entered[3] <- 0
ratio.data$exited[2] <- 0
ratio.data$entered[4] <- ratio.data$exited[1]

# Hard-code values once satisfactory values have been generated
ratio.data$entered <- c(12,6,0,1)
ratio.data$exited <- c(1,0,4,6)

interval.music <- { list(
  A = 220.00
  , `A#` = 233.08
  , B = 246.94
  , `C (middle)` = 261.63
  , `C#` = 277.18
  , D = 293.66
  , `D#` = 311.13
  , E = 329.63
)}

interval.music %<>% list_merge(!!!(seq_along(interval.music)-4)/2);

interval.music %<>% list_merge(!!!(rnorm(n = length(interval.music), mean = 20, sd = 60) |> round(2)));

sigmoid.viz <- (\(x){
  plot_ly(
    x = x
    , y = book.of.features::sigmoid(x, k = .1)
  ) |> 
    config(mathjax = "cdn") |>
    layout(
      title = "<span style='font-family:Georgia'>Sigmoid Function</span><br><sup>Note the ranges of both axes</sup>"
      , xaxis = list(title = TeX("\\text{X}"), showgrid = FALSE, zeroline=FALSE)
      , yaxis = list(title = TeX("f(x)"), showgrid=FALSE)
      , margin = list(b = -10, t = -.75)
    ) |>
    add_annotations(
      text = TeX("f(x)=\\frac{L}{1 + e^{-k(x-x_0)}}")
      , font = list(size = 50)
      , x = -5, y = 0.85, ax = -20
      , showarrow = FALSE
    ) |>
    add_annotations(
      text = TeX("\\text{lim}_{x\\to\\infty}f(x)=0")
      , font = list(size = 15)
      , x = -10, y = 0.03, ax = 50, ay = -50
    )
})(-10:10);

papercut.viz <- spsUtil::quiet({ book.of.utilities::call.recursion(
  x = 0
  , fun = \(i) list(x = i, y = 2^(-i))
  , test = \(i) i$x < 20
  , nxt = \(i) i$x + 1
  , max.iter = 20
  , simplify = FALSE
  ) |>
    map_dfr(unlist) |>
    as.data.table() |>
    architect::define(
      text = (\(x){
        i <- c("Small", "Smaller", "Really small", "Get a microscope!", "Approaching zero!!!")
        k <- outer(x, c(1E-0, 1E-1, 1E-2, 1E-3, 1E-4), `<`) |> rowSums()
        i[k]
      })(y)) |>
    plot_ly(
      x = ~x
      , y = ~y
      , color = ~y
      , size = ~10 * y
      , width = 720
      , height = 550
      , name = "The half of it"
      , hoverinfo = "text+info"
      , hovertext = ~glue::glue("Piece size: {ifelse(y < 0.125, text, y)}")
      , stroke = I("#000000")
      , type = "scatter"
      , mode = "markers"
    ) |> 
    config(mathjax = "cdn") |>
    # hide_colorbar() |>
    colorbar(title = list(text = "<span style='font-family: Georgia'>f(x) = 2<sup>-x</sup></span>")) |>
    layout(
      title = "Cutting Into Halves<br><span style='font-size:smaller; font-family: Georgia; ' >(How 1,000 papercuts happen)</span>"
      , margin = list(t = -11, b = -11)
      , plot_bgcolor = "#EFEFEF"
      , xaxis = list(title = TeX("x\\text{ (# of halves)}"), gridcolor = "#CCCCCC")
      , yaxis = list(title = TeX("f(x)"), gridcolor = "#CCCCCC")
      )
});

# HTML TAGS ----
references <- { tags$ul(
    list(
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
}