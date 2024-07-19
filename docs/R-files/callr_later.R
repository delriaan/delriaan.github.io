# `later::later()` Objects
callr_later <- function(
  CALLR_FUNC 
  , ...
  , LATER_OBJ_NAME = "check_this"
  , BG_OBJ_NAME = "this_action"
  , OUTPUT_NAME = "callr_later_output"
  , LATER_DELAY = 5
  , ASSIGN_ENV = .GlobalEnv
  ){
  #' Call R Later
  #' 
  #' @param CALLR_FUNC
  #' @param ... A named list of objects to be exported to the background process to call later.
  #' @param LATER_OBJ_NAME,BG_OBJ_NAME,OUTPUT_NAME Names for the \code{\link[later]{later}} \emph{callback function}, \emph{background processor object}, and \code{output}, respectively
  #' @param LATER_DELAY The seconds of delay to use for the \code{\link[later]{later}} callback function 
  #' @param ASSIGN_ENV The environment for assignment for \code{LATER_OBJ_NAME}, \code{BG_OBJ_NAME}, \code{OUTPUT_NAME}
  #'  
  #' @return The output of \code{CALLR_FUNC} to \code{OUTPUT_NAME} in \code{ASSIGN_ENV}
  
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(callr)
    , require(later)
    ))
  
  LATER_OBJ_NAME <- rlang::enexpr(LATER_OBJ_NAME) |> as.character();
  BG_OBJ_NAME <- rlang::enexpr(BG_OBJ_NAME) |> as.character();
  OUTPUT_NAME <- rlang::enexpr(OUTPUT_NAME) |> as.character();
  
  rm(list = intersect(ls(ASSIGN_ENV), c(LATER_OBJ_NAME, BG_OBJ_NAME, paste0(LATER_OBJ_NAME, ".cancel"))), envir = ASSIGN_ENV);
  LATER_FUNC <- function(){ ASSIGN_ENV[[LATER_OBJ_NAME]] }
  
  makeActiveBinding(sym = LATER_OBJ_NAME, fun = function(){
    obj <- eval(rlang::sym(BG_OBJ_NAME));
    
    if (!obj$is_alive()){
      cat(sprintf("[%s] Completed!", Sys.time()), sep = "\n");
      
      assign(OUTPUT_NAME, obj$get_result(), envir = ASSIGN_ENV);
    } else {
      cat(sprintf("[%s] Still alive ...", Sys.time()), sep = "\n");
      
      # This is a recursive call using an active binding (defined below)
      cancel_check <- later::later(func = LATER_FUNC, delay = LATER_DELAY, loop = later::global_loop());
      
      if (!paste0(LATER_OBJ_NAME, ".cancel") %in% ls(ASSIGN_ENV)){
        ASSIGN_ENV[[paste0(LATER_OBJ_NAME, ".cancel")]] <- cancel_check
      }
    }
  }, env = ASSIGN_ENV)
  
  # Call ... R ... Later
  # If `BG_OBJ_NAME` has completed, return the result and possibly to other things
  # If `BG_OBJ_NAME` is still active, check `BG_OBJ_NAME` in `LATER_DELAY` seconds
  assign(BG_OBJ_NAME, {
    callr::r_bg(func = CALLR_FUNC
                , args =  rlang::dots_list(..., .named = TRUE, .ignore_empty = "all", .homonyms = "last")
                )
  }, envir = ASSIGN_ENV);
}

