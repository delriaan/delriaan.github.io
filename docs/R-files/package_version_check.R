this_desc <- desc::desc("pkg/DESCRIPTION")

ip <- installed.packages()

ip[intersect(this_desc$get_deps()[, "package"], rownames(ip)), "Version"] |>
  (\(x){ 
    res <- sprintf("%s (>= %s)", names(x), x) |> paste(collapse = ", \n")
    cli::cli_alert_info("Copy the following to \"pkg/Description\":")
    cat(res)
    writeClipboard(res)
    invisible(res)
  })()
