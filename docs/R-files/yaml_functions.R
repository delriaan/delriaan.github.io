new_yaml_config <- \(...){
  rlang::list2(...) |> 
    yaml::write_yaml(file = "_config.yaml") 
}

parse_yaml_config <- \(yaml_config, .debug = FALSE){
  if (.debug) browser();
  if (missing(yaml_config)){
    stop("A yaml configuration file or input is required: aborting ...");
  }
  
  if (any(grepl("yaml", yaml_config))){
    yaml::read_yaml(yaml_config)
  } else {
    return(yaml_config) 
  }
}