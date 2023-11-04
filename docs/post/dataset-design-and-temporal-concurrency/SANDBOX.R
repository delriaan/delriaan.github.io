window_example <- rstudioapi::getSourceEditorContext()$path |> 
  dirname() |> 
  paste0("/Window Example.svg") |>
  magick::image_read_svg() |> 
  magick::image_resize(geometry = magick::geometry_size_percent(20))
