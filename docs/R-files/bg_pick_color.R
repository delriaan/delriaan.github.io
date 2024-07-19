bg_pick_color <- function(port = parallelly::freePort()){
  #' Background Color Picker
  #' 
  #' @param port The port number to use for the background process.
  #' 
  #' This function creates a background process that allows the user to 
  #' pick a color using \code{\link[colorspace]{hcl_color_picker}} via the browser.
  #' 
  #' @details
  #' This function overloads the \code{\link[colorspace]{hcl_color_picker}} function by adding a 'port' argument and is done by creating a function from the original expression tree and updating specific pieces. The function is then executed in a background process using \code{\link[callr]{r_bg}}. If the process is alive, the user is directed to the browser to pick a color. If the process is not alive, the user is notified and the process is killed. Exiting the application via the browser also kills the process.
  #' 
  #' @return The color picked by the user.
  
  assertive::assert_all_are_true(c(
    require(callr)
    , require(colorspace)
    , require(parallelly)
    ))

  # :: Create a wrapper for the hcl_color_picker function that takes 'port' as an argument:
  bg_color_fun <- new("function");
  bg_color_fun_body <- functionBody(colorspace::hcl_color_picker);
  
  # Append 'port' to the formal arguments of the original function:
  bg_color_fun_body[[6]][[3]][["port"]] <- rlang::expr(port);
  
  # Populate the function elements
  functionBody(bg_color_fun) <- bg_color_fun_body;
  formals(bg_color_fun) <- rlang::exprs(!!!formals(colorspace::hcl_color_picker), port = parallelly::freePort())
  # bg_color_fun
  
  bg_color_proc <- callr::r_bg(
    \(fun, port){ fun(port = port) }
    , args = list(port = port, fun = bg_color_fun)
    , stdout = "bg_proc_output.txt"
    , stderr = "bg_proc_error.txt"
    );
  
  if (bg_color_proc$is_alive()){ 
    browseURL(paste0("http://localhost:", port))
  } else {
    print("The background process is not alive.")
    bg_color_proc$kill()
  }
  
  bg_color_proc$get_result();
}
