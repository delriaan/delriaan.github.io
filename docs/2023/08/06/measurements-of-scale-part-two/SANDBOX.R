sprintf("X: \\{%s\\}", paste(ratio.data, collapse = ", ")) |> TeX()

tags$style(
  paste(".warning {background-color:#CCCCCC"
        , "border-top: solid 2px #AA0000"
        , "border-bottom: solid 2px #AA0000}"
        , sep = "; "
  )
  , ".warning:first-word {color:#AA0000; }"
)

book.of.utilities::call.recursion(
  x = 20
  , fun = \(i) i
  , test = \(i) TRUE
  , nxt = \(i) i
  , max.iter = 10
  , simplify = FALSE
  ) |>
  unlist()

(\(x0, x1) plot(x = 1:x1, y = log10(100/raise_to_power(1:x1, 2))))(x0 = 10, x1 = 100)
