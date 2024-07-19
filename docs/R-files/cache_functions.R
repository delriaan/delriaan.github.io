cache_prep <- function(x, env = .GlobalEnv){
  #' Prepare Data to Save in Cache
  #' 
  #' \code{cache_prep} prepares an object for saving to cache via \code{\link[cachem]{cache_disk}}, \code{\link[cachem]{cache_layered}}, or \code{\link[cachem]{cache_mem}}. The object is augmented with attributes used to save and retrieve from cache (see \code{\link[cachem]{cache_disk}}).
  #' 
  #' @section The Original Environment:
  #' The original environment is captured and prefixed to the cached item name, always in lower case as required by \code{cachem}.
  #' 
  #' @param x The name (symbol or string) of the input data
  #' @param env The name (symbol or string) of the source environment (used in the call to \code{\link[utils]{find}})
  #' 
  #' @return The input augmented with attributes used to save and retrieve from cache (see \code{\link[cachem]{cache_disk}}).
  #' 
  #' @family Cache functions
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(cachem)
    , require(glue)
    , require(stringi)
    , require(purrr)
    , require(data.table)
    ))
  
  env.nm <- rlang::enexpr(env) |> as.character()
  if (grepl("GlobalEnv", env.nm)){ env.nm <- "global" }
  
  nm <- rlang::enexpr(x) |> as.character()
  x <- get(nm, envir = as.environment(env))
  
  data.table::setattr(x, "save_ts", Sys.time()) |> 
    data.table::setattr("orig_name", nm) |> 
    data.table::setattr("save_name", paste(env.nm |> tolower(), tolower(nm), sep = "_")) |>
    data.table::setattr("save_env", env.nm)
}
#
cache_load <- function(cache, pattern = ".", ucase_env = TRUE, .debug = FALSE){
  #' Load from Disk Cache
  #' 
  #' \code{cache_load} loads objects saved to cache via \code{\link[cachem]{cache_disk}}, \code{\link[cachem]{cache_layered}}, or \code{\link[cachem]{cache_mem}}. Cached objects are restored to the environment from which they were taken when saved using \code{\link{cache_prep}}. 
  #' 
  #' @section The Original Environment:
  #' \itemize{
  #' \item{The original environment is parsed from the object name as \code{[env]_[obj]}.}
  #' \item{If the original environment has numbers, they are included in the environment name.}
  #' \item{Environment names are automatically capitalized: this is the only additional restriction on naming beyond what \code{cachem} requires.}
  #' }
  #' 
  #' @param cache A \code{\link[cachem]{cache_disk}} object
  #' @param pattern (string) A pattern to match cached keys
  #' @param ucase_env (logical) Should the environment object name be converted into all uppercase or used as-is?
  #' 
  #' @return A logical scalar indicating a successful restoration
  #' @family Cache functions
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(cachem)
    , require(glue)
    , require(stringi)
    , require(purrr)
    ))
  
  .load_queue <- grep(pattern, x = cache$keys(), value = TRUE)
  
  if (rlang::is_empty(.load_queue)){
    message(glue::glue("Key not found using pattern '{pattern}'")); 
    return() 
  }
  
  purrr::walk(.load_queue, \(x){
    if (.debug){ browser() }
    
    obj <- cache$get(x);
    
    # if (grepl("[0-9]", x)){ browser() } else { return() }
    
    # `env_obj` contains the pattern combination for the environment 
    # and object to be assigned to it.
    list(
      env_name = stringi::stri_extract_first_regex(x, "^[a-z]+(_[0-9]+)?")
      , obj_name = stringi::stri_replace_first_regex(x, "^[a-z]+(_[0-9]+)?[_]", "")
      ) |>
      list2env(envir = environment());
    
    # Finalize the environment name for the object:
    env_name <- ifelse(
      grepl("global", env_name)
      , ".GlobalEnv"
      , ifelse(
          ucase_env
          , toupper(attributes(obj)$save_env)
          , attributes(obj)$save_env
          )
      );
    
    parent_env <- if (env_name == ".GlobalEnv"){
      .GlobalEnv
      } else {
        rlang::inject(find(!!env_name)) |> 
          rlang::sym() |> 
          eval(envir = .GlobalEnv);
      }
    
    if (rlang::is_empty(parent_env)){
      parent_env <- .GlobalEnv;
      parent_env[[env_name]] <- new.env()
    }
    
    # Finalize the object name:
    obj_name <- if (rlang::is_empty(attr(obj, "orig_name"))){
        stringi::stri_replace_first_fixed(x, glue::glue("(global_)|({env_name})"), "")
      } else { 
        attr(obj, "orig_name")
      }
    
    if (env_name %in% search()){
      assign(obj_name, obj, envir = as.environment(env_name));
    } else if (env_name == ".GlobalEnv"){
      assign(obj_name, obj, envir = parent_env);
    } else {
      parent_env[[env_name]][[obj_name]] <- obj;
    }
  })
}
#
cache_save <- function(x, cache){
  #' Save to Cache
  #' 
  #' Save an object to \code{cache} created from a call to \code{cache_load}
  #' 
  #' @family Cache functions
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(cachem)
    , require(glue)
    , require(stringi)
    , require(purrr)
    ))
  
  cache$set(attr(x, "save_name"), x)
}
