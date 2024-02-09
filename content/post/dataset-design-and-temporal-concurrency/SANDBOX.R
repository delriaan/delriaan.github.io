library(book.of.workflow)
load_unloaded(magrittr, rsvg, plotly, purrr)
#
# :: Image Manipulation ----
hourglass.png <- magick::image_read("C:/Users/sapie/GitHub/delriaan.github.io/static/hourglass.png");

img <- hourglass.png |> magick::image_data();
img <- magrittr::set_attr(img, "dimnames", list(c("red", "green", "blue", "alpha"), NULL, NULL));
img_vec <- purrr::array_branch(img, 1) |> 
  purrr::reduce(\(x, y) (as.integer(x) + as.integer(y))) |> 
  matrix(nrow = nrow(img[1,,]));

crop_x <- img_vec |> apply(1, \(i){ book.of.utilities::ratio(i, type = "cumulative", d = 4) }) |> colSums() |> (\(i) max(i) - i)()
crop_y <- img_vec |> apply(2, \(i){ book.of.utilities::ratio(i, type = "cumulative", d = 4) }) |> rowSums() |> (\(i) max(i) - i)()

which(crop_x == 0)
which(crop_y == 0)

magick::image_crop(hourglass.png, geometry = magick::geometry_area(y = seq_along(crop_y), x = which(crop_x > 0)))

# :: Other ----

W <- list(start = 5, stop = 15)
H <- local({
  events <- c(0, 4, 8) |> rlang::set_names(paste0("Event ", LETTERS[1:3]));
  imap(events, \(y, name){
    x <- sample(1:5, 1);
    xend <- x + sample(5:15, 1);
    yend <- y
    color <- rgb(runif(3, .1, .3) |> matrix(ncol = 3));
    mget(ls())
  })
})

p <- plot_ly() |>
  add_segments(x = W$start, xend = W$start, y = -3, yend = 13, color = I("#000000")
               , mode = "markers", marker = list(size = 10, color = I("#000000"))
               , name = "W (start)", legendgroup = "Report Window") |>
  add_segments(x = W$stop, xend = W$stop, y = -3, yend = 13, color = I("#000000")
               , mode = "markers", marker = list(size = 10, color = I("#000000"))
               , name = "W (end)" , legendgroup = "Report Window")
  
reduce(H, .f = \(cur, nxt){
    rlang::expr(add_segments(p = cur, !!!nxt, mode = "markers", marker = list(symbol = "diamond", size = 15))) |> eval()
  }, .init = p) |>
  layout(
    margin = list(t = -5, b = -5)
    , xaxis = list(title = list(text = "Time"), range = c(0, 20), zeroline = FALSE)
    , yaxis = list(title = list(text = "")
                   , range = c(-5, 15)
                   , showgrid = FALSE, zeroline = FALSE, showline = FALSE, showticklabels = FALSE)
    )
