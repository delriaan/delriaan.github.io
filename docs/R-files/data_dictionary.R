data_dictionary <- R6::R6Class(
  classname = "data_dictionary"
  , public = list(
      initialize = function(){
        self$terms <- new.env()
        private$cipher <- sodium::keygen()
        
        return(invisible(self))
      }
      , get_def = \(..., i = 0, .debug = FALSE){
        #' Get a Dictionary Definition
        #' 
        #' @param ... \code{\link[rlang]{dots_list}} expressions that form REGEX patterns to use in search. Objects of class \code{definition} are returned
          if (.debug) browser()
          pattern = paste(sprintf("(%s)", as.character(rlang::enexprs(...))), collapse = "|");
          
          queue <- mget(ls(self$terms), envir = self$terms)
          
          return(invisible(queue |>
            purrr::iwalk(\(x, nm){
              if ("definition" %in% class(x)){
                res <- grep(pattern = pattern, x = glue::glue("[{nm}] {x@summary}"), value = TRUE, ignore.case = TRUE)
                
                if (!rlang::is_empty(res)) cli::cli_alert_info(res)
              } else {
                cli::cli_alert_warning("{nm} is not of class 'definition': ignoring ...")
                NULL
              }
            }) |>
            purrr::compact()))
        }
      , add = \(name, definition, description, context, ...){
          #' Add a definition
          #' 
          #' @param name (symbol|string) The term label/name
          #' @param definition,description,context See \code{definition}
          #' @param ... Serializable elements used to "tag" the entry. A use case could be to provide dynamic attributes from the referenced data that indicate something has changed.
          name <- as.character(rlang::enexpr(name))
          
          # Create the definition object and signature:
          # The signature will change if the underlying definition changes
          res <- definition(definition, description, context)
          
          tags <- 0
          
          if (...length() > 0){
            tags <- rlang::enexprs(...)
          }
          
          new_sig <- serialize(object = list(res, tags), connection = NULL) |>
            sodium::sha256(key = private$key)
          
          res %<>% magrittr::set_attr("signature", new_sig)
        
          # Check for the existence of the object by name:
          if (name %in% ls(self$terms)){
            # Retrieve the object's signature:
            cur_sig <- self$terms[[name]] |> attr("signature")
            
            # If the signatures don't match, conditionally overwrite; otherwise, do nothing:
            if (!identical(cur_sig, new_sig)){
              if (svDialogs::okCancelBox("Overwrite exiting object?")){
                assign(name, res, envir = self$terms)
                cli::cli_alert_success("{name} added/updated")
              } else {
                cli::cli_alert_info("No action taken")
              }
            } else {
              cli::cli_alert_info("No changes detected")
            }
          } else {
            assign(name, res, envir = self$terms)
            cli::cli_alert_success("{name} added/updated")
          }
          
          return(invisible(self))
        }
      , remove = \(name){
          #' Remove a definition
          #' 
          #' @param name (string|symbol) The definition to remove
          name <- as.character(rlang::enexpr(name))
          
          spsUtil::quiet(rm(list = name, envir = self$terms))
        
          if (name %in% ls(self$terms)){
            cli::cli_alert_warning("{name} not removed")
          } else {
            cli::cli_alert_success("{name} removed")
          }
          return(invisible(self))
      }
      , help <- \(i){
          #' Help Me Out!
          #' 
          #' \code{$help} will generate help documentation or text related to this class using \code{\link[docstring]{docstring}}
          #' 
          #' @param i (symbol|string) The name of a method or field
          #' 
          #' @return Invisibly, the class environment
          
          if (missing(i)){
            i <- tcltk::tk_select.list(
              title = "Choose a function to view documentation"
              , choices = data_dictionary$public_methods |> names()
              )
          } else {
            i <- rlang::enexpr(i) |> rlang::as_label();
          }
          
          if (purrr::is_function(data_dictionary$public_methods[[i]])){ 
              assign(i, data_dictionary$public_methods[[i]]);
              rlang::expr(docstring::docstring(!!as.name(i))) |> eval()
          }
          invisible(self);
        }
      , terms = NULL
      )
  , private = list(cipher = NULL)
  )

# :: Define a <S7>[definition] class and print method for handling objects in `data_dictionary`: ----
if ("print.definition" %in% ls()) rm(print.definition);
print.definition <- S7::new_generic(name = "print", dispatch_args = "x");

# S7 Class definition
definition <- { S7::new_class(
  name = "definition"
  , properties = list(
      definition = S7::new_property(
        class = S7::class_expression
        , default = NULL
        , setter = function(self, value){
            self@definition <- value
            self; 
          }
        )
      , description = S7::new_property(class = S7::class_character, default = "(No description)")
      , context = S7::new_property(class = S7::class_character, default = "global")
      , summary = S7::new_property(
          class = S7::class_character
          , default = ""
          , getter = function(self){
              glue::glue(
                "<{self@context}> {self@description}:\n -> {self@definition}"
                , .sep = " "
                );
            }
          )
      )
  )
}

S7::method(print.definition, definition) <- function(x){
  cli::cli_alert_info(glue::glue(
    "<{x@context}> {x@description}:\n -> {x@definition}"
    , .sep = " "
    ));
  
  return(invisible(x));
}
