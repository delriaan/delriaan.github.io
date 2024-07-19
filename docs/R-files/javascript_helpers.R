hint_js <- function(..., tags, contexts = "all", out.file = "", fade_speed = 10, toggle.options = list(open = "[+]", close = "[-]")){
  #' JQuery Hint Toggle Generator
  #'
  #' This function takes the user-supplied arguments and inputs and creates Javascript code designed to toggle DOM elements. 
  #'
  #' @param ... 
  #' @param tags (string[]) Each value provides the tags for which toggle events should be processed
  #' @param contexts (string[]) Each value represents a contextualizing tag attribute within which toggle events are handled
  #' @param out.file See \code{\link[base]{cat}}
  #' @param fade_speed JQuery toggle speed
  #' @param toggle.options Length-2 list having names "open" and "close": elements provide the toggle text values.
  #'
  #' @return An anonymous function, optionally writing the generated code to \code{out.file}. The generated code is automatically saved to the \code{hint_js} option, accessed via \code{options("hint_js)[[1]]}.
  #' 
  #' @export
  #'
  #' @examples
  contexts <- contexts[seq_along(tags)];
  contexts[is.na(contexts)] <- contexts[1];
  assertive::assert_is_list(toggle.options, severity = "stop");
  assertive::assert_is_of_length(toggle.options, n = 2L, severity = "stop");
  
  assertive::assert_all_are_true(c(
    is.list(toggle.options)
    , rlang::has_length(toggle.options, 2L)
    , all(c("open", "close") %in% names(toggle.options))
    # Required Libraries::
    , require(glue)
    , require(htmltools)
    )
    , severity = "stop"
    );
  
  fun_start <- "\n$(document).ready(function(){\n  // Initially, hide all toggle DOM elements:";
  
  init_tag_context_hide <- purrr::map2_chr(tags, contexts, \(i, j){
    glue::glue("  $(\"{i}[context='{j}']\").hide();");
  });
  
  init_toggle_context_role.find_hint.set_text <- sapply(unique(contexts), \(i){
    glue::glue("  $(\"[role='toggle'][context='{i}']\").first().find(\"hint\").first().text(\"{toggle.options$close}\");");
  });
  
  init_tag_context_show_first <- purrr::map2_chr(tags, contexts, \(i, j){
    glue::glue("  $(\"{i}[context='{j}']\").first().show();");
  });
  
  tags_toggle_callback <- {
    rlang::inject(paste(
    "\n  // Toggle Event Callbacks"
    , "  $(\"[role='toggle']\").click("
    , "    function(){"
    , "      lgrp = $(this).attr(\"toggleGroup\");"
    , "      hint = $(this).find(\"hint\").first();"
    , "      "
    , "      if (hint.text() == \"{toggle.options$open}\"){{ hint.text(\"{toggle.options$close}\"); }}" |> glue::glue()
    , "      else {{ hint.text(\"{toggle.options$open}\"); }}" |> glue::glue()
    , " "
    , "      // Attach an event to each of the target DOM elements (created when R function 'hint_js()' was invoked):"
    , sapply(tags, \(i) glue::glue("      $(\"{i}[toggleGroup='\" + lgrp + \"']\").fadeToggle({fade_speed});")) |>
        paste(collapse = "\n")
    , "    }); "
    , " "
    , "  // Show the first element in each context:"
    , sep = "\n"
    ))
  }
  
  fun_end <- "});\n"
  
  out <- { rlang::inject(paste(
    fun_start
    , init_tag_context_hide |> paste(collapse = "\n")
    # , init_toggle_context_role.find_hint.set_text |> paste(collapse = "\n")
    , tags_toggle_callback |> paste(collapse = "\n")
    , init_tag_context_show_first |> paste(collapse = "\n")
    , fun_end
    , sep = "\n"
    ));
  }

  if (out.file != ""){ cat(out, file = out.file); }
  
  options(hint_js = out);

  # Anonymous function output:
  function(..., role = "toggle", context = "all", toggleGroup = "0", class = ""){
    #' Drop a Toggle Hint
    #'
    #' \code{drop_hint} creates a \code{\link[htmltools]{span}} HTML tag containing attributes that, in conjunction with JQuery calls, will mark content to toggle visibility when the created \code{\link[htmltools]{span}} tag is clicked.
    #' Arguments \code{context} and \code{toggleGroup} provide thematic and theme-element-specific control over which elements respond to the JQuery toggle event.  Elements responding to toggle events should be set as \code{ <tag context='' toggleGroup = ''> }
    #'
    #' @param ... Additional strings that will be combined (via \code{\link[base]{paste0}}) to make child content of the tag (HTML tags supported)
    #' @param role (string | "toggle") Elements with attribute 'role' set to this value will function as the JQuery toggle event trigger
    #' @param context (string | "all") Elements with attribute 'context' set to this value will respond to the JQuery toggle event
    #' @param toggleGroup (string | "0") Elements with attribute 'toggleGroup' set to this value will respond to the JQuery toggle event
    #' @param class (string | "") The CSS class for the tag
    #'
    #' @return An HTML \code{\link[htmltools]{taglist}}
    text_content <- if (...length() == 0) {""} else { paste0(c(...), " ") |> htmltools::HTML(); }
    
    htmltools::tags$span(
      role = role
      , context = context
      , toggleGroup = toggleGroup
      , class = class
      , text_content
      # The following creates a custom HTML tag. `toggle.options` resides in the parent.environment (`hint_js()`)-:
      , htmltools::tag("hint", varArgs = list(toggleGroup = toggleGroup, htmltools::HTML(toggle.options$open)))
      );
  }
}
