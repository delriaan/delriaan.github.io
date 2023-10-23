blogdown::stop_server()

file.copy(from = c("markdown.css"), to = "content", overwrite = TRUE)

blogdown::build_site(local = TRUE, run_hugo = !TRUE, build_rmd = TRUE)

blogdown::serve_site(port = 4321, daemon = TRUE)

browseURL("http://localhost:4321")

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
