library(magrittr)
library(rsvg)
library(foreach)

# :: ----
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

# :: ----
h_1 <- 12
h_2 <- 10
h_3 <- 5

len <- c(h_1, h_2, h_3) |> prod()

foreach(i = seq_len(h_1), .combine = c) %:%
  foreach(j = seq(h_1+1, h_2), .combine = c) %:% 
    foreach(k = seq(h_2+1, h_3), .combine = c) %do% {
      c(i, j, k)
    } |>
  array(dim = c(h_3, h_2, h_1))
