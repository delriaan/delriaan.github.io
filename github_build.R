blogdown::hugo_build(local=TRUE)

file.meta.public <- paste0("public/", dir("public", include.dirs = TRUE)) |> 
  lapply(file.info) |> 
  purrr::reduce(rbind) |>
  data.table::as.data.table(keep.rownames = TRUE, key="mtime")

if (any(as.Date(file.meta.public$mtime, tz = "EST") == Sys.Date())){
  file.copy(
    from = file.meta.public$rn
    , to = "docs"
    , overwrite = TRUE
    , recursive = TRUE
    )
  }
