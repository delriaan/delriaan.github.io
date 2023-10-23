blogdown::stop_server()

file.copy(from = c("markdown.css"), to = "content", overwrite = TRUE)

blogdown::build_site(local = TRUE, run_hugo = TRUE, build_rmd = TRUE)
# blogdown::hugo_build(local = TRUE)
blogdown::serve_site(port = 4321, daemon = TRUE)

browseURL("http://localhost:4321")

file.meta.public <- paste0("public/", dir("public", include.dirs = TRUE)) |> 
  lapply(file.info) |> 
  purrr::reduce(rbind) |>
  data.table::as.data.table(keep.rownames = TRUE, key="mtime") 

updated_file_check <- file.meta.public$mtime >= (Sys.time() - lubridate::hours(4)); 
if (any(updated_file_check)){
  file.copy(
    from = file.meta.public[updated_file_check, rn]
    , to = "docs"
    , overwrite = TRUE
    , recursive = TRUE
    )
  }
