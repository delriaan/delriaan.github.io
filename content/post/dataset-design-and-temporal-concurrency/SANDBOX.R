library(magrittr)
library(rsvg)

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

combinat::

len <- c(h_1, h_2, h_3) |> prod()

for(x in sample(h_1, h_1)){
  for(y in sample(h_2, h_2)){
    for(z in sample(h_3, h_3)){
      assign("inspect", purrr::accumulate(c(x, y, z), c), envir = .GlobalEnv)
    }
  }
}
