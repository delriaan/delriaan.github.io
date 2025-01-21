load_nlp_functions <- function(..., auto = FALSE){
  #' Load NLP Functions
  #' 
  #' This function loads predefined functions related to NLP tasks. 
  #' 
  #' @param ... (character) The names or patterns of the functions to load
  #' @param auto (logical) Automatically load matched functions?
  #' 
  #' @return None: the matched functions are assigned to the calling environment.
  assertive::assert_all_are_true(c(
    # Required Libraries:
    require(magrittr)
    , require(purrr)
    , require(stringi)
    , require(udpipe)
    , require(summarytools)
    , require(text2vec)
    , require(dplyr)
    ))
  env <- rlang::caller_env();
  f_list <- rlang::enexprs(...) |> sapply(rlang::as_label);
    
  # :: Text Processing Functions ----
  tokenizer_factory <- \(fun, subStr = 0, min_len = 1L, ...){
    #' Tokenizer Factory
    #' 
    #' @param fun The function to serve as the tokenizer. Tokenizing functions 
    #' should return a list of vectors, one element per document tokenized.
    #' @param subStr (logical|integer) Lengths of sub-strings to produce:
    #' \itemize{
    #' \item{TRUE: Read user input from console (must evaluate to integer)}
    #' }
    if (missing(fun)){ 
      fun <- rlang::expr({
          assertive::assert_all_are_greater_than_or_equal_to(min_len, 1L);
          
          .tokens <- stringi::stri_extract_all_regex(x, pattern = "([:alpha:]+)", simplify = FALSE, omit_no_match = TRUE)
          lapply(.tokens, \(i) i[stringi::stri_length(i) >= min_len]);
        })
    }
    
    stopifnot(
      is.numeric(subStr) || is.logical(subStr)
      , is.infinite(min_len) || min_len > 0
      , is.function(fun)
      );
    
    if (subStr == TRUE){ 
      subStr <- readline("Enter substring length for tokenization: ") |> as.numeric();
      assertive::assert_is_numeric(subStr);
    }
    
    as.function(rlang::exprs(x = , min_len = !!min_len, !!functionBody(fun)));
  }
  
  string_quantize <- \(x, max_len, max.iter = 1){
    #' Quantize String Lengths
    #' 
    #' This function takes a vector of strings, splits and pads them to a specified length.
    #' 
    #' @param x A vector of strings
    #' @param max_len The maximum length of the strings
    #' @param max.iter The maximum number of iterations to run (see \code{\link[book.of.utilities]{call.recursion}})
    #' 
    #' @return A vector of strings of length \code{max_len}
    .fun <- \(i){ 
      .retain <- i[stringi::stri_length(i) == max_len];
      .process <- i[stringi::stri_length(i) > max_len];
      
      if (rlang::is_empty(.process)){
        .process <- i[stringi::stri_length(i) < max_len];
        return(c(.retain, stringi::stri_pad_right(.process, max_len, pad = " ")));
      } 
      
      purrr::list_simplify(
        rlang::list2(
          !!!.retain 
          , stringi::stri_sub(.process, length = max_len)
          , stringi::stri_sub(.process, from = max_len + 1, to = stringi::stri_length(.process))
        )
        , ptype = ""
      );
    }
    
    book.of.utilities::call.recursion(
      x = x
      , fun = .fun
      , test = \(i){ any(sapply(i, stringi::stri_length) > max_len) }
      , nxt = .fun
      , max.iter = max.iter
    ) |>
      purrr::accumulate(c) |> 
      unlist()
  }

  encode_position <- \(k, d, n = 1E4){
    #' Encode Sequence Positions
    #' 
    #' @param k (int) The length of the sequence to encode
    #' @param d (int) The embedding dimension
    #' @param n (numeric) User-supplied base
    #' 
    #' @references \url{https://machinelearningmastery.com/a-gentle-introduction-to-positional-encoding-in-transformer-models-part-1/}
    #' 
    #' @return A position-encoded vector created from the scaled column sums of the array
    fun <- \(k, i){
      x <- n^(-2 * i / d)
      # browser()
      # Forces every other position to be sin(?) or cos(?)
      rbind(sin(x * k), cos(x * k)) |> as.vector()
    }
    
    k <- seq_len(k) - 1;
    
    i <- book.of.features::bin.windows(seq_len(d) - 1, use.bin = 2) |> 
        attr("bin.map") %>% 
        .$label |> 
        length() |> 
        seq_len() - 1
    
    sapply(k, fun, i) |> t() |> colSums() |>scale() |> as.vector()
  }  
  
  pos_xform <- \(x, object, parallel.cores = 1L, upos = c("ADJ", "ADP", "ADV", "AUX", "CCONJ", "DET", "INTJ", "NOUN", "NUM", "PART", "PRON", "PROPN", "PUNCT", "SCONJ", "SYM", "VERB", "X"), ...){
    #' Part-of-Speech Transform
    #' 
    #' \code{pos_xform} executes \code{\link[udpipe]{udpipe}} on \code{doc}, 'one-hot' encodes the 'upos' feature, and derives column-sums \emph{by document}.
    #' 
    #' @param doc,object,parallel.cores,... See \code{\link[udpipe]{udpipe}}
    #' @param upos Universal-Part-of-Speech labels
    #' @return A length-two list of \code{[annotations tabular data, UPOS column-sum array]}, the latter being derived from the former.
  
    upos <- match.arg(upos, upos, several.ok = TRUE);
    
    # Basic output:
    annotations <- udpipe::udpipe(x = x, object = object, parallel.cores = parallel.cores, ...) |>
      purrr::modify_at(c("upos", "xpos", "dep_rel"), factor) |>
      data.table::as.data.table()
    
    # Column Sums:
    annotations_profile <- annotations |> 
      f_split(~doc_id) |> 
      purrr::map(\(x){ 
        book.of.features::logic_map(x$upos, bvec = upos, sparse = FALSE) |> 
          colSums() |> 
          matrix(nrow = 1, dimnames = list(NULL, upos))
      }) |> 
      purrr::reduce(rbind)
    
    # Return the list:
    return(mget(ls(pattern = "^annot")))
  }
  
  # :: Vector Derivation Pipeline Functions ----
  colloc_rinse_repeat <- function(colloc, tkn_itr, rate = 0.1, loop = 0, i = 1, output_dir = getwd(), ...){
    #' Collocation Rinse and Repeat
    #' 
    #' Use this function to incrementally fit a \code{\link[text2vec]{Collocations}} collocation model.
    #' 
    #' @param colloc A \code{\link[text2vec]{Collocations}} object
    #' @param tkn_itr A \code{\link[text2vec]{itoken}} object
    #' @param rate The learning rate
    #' @param loop The number of iterations to run
    #' @param i The current iteration
    #' @param output_dir The directory to save the HTML file generated from \code{\link[summarytools]{view}} (no trailing '/' needed)
    #' @param ... Additional arguments to \code{\link[summarytools]{view}}
    #' 
    .refit <- (loop > 0) & (i < loop);
    
    action <- rlang::expr({
      # Incremental Fit:
      colloc$partial_fit(it = tkn_itr);
      
      # Collocation Statistics:
      .colloc_stats <- colloc$collocation_stat |> 
        dplyr::filter(!grepl("^[0-9]", prefix), !grepl("^[0-9]", suffix)) |> print();
      
      # Statistics comparison:
      .colloc_stats %$% cor(as.matrix(cbind(pmi, gensim, llr, lfmd))) |> print();
      
      # View Statistics:
      colloc$collocation_stat |> 
        dplyr::filter(!grepl("^[0-9]", prefix), !grepl("^[0-9]", suffix)) |> 
        summarytools::dfSummary() |> 
        summarytools::view(
          file = file.path(output_dir, "colloc_stats.html")
          , report.title = "Collocation Statistics"
          , ...
          );
      
      # Refit?:
      if (!.refit & (loop == 0)){ .refit <- askYesNo("Refit? ") == TRUE }
    });
      
    eval(action);
    
    # Prune and Partial Fit:
    while(.refit == TRUE){
      i <- i + 1;
      
      dplyr::filter(.colloc_stats, or(pmi >= quantile(pmi, rate), lfmd >= quantile(lfmd, rate))) |> 
        (\(x) colloc$prune(pmi_min = min(x$pmi), lfmd_min = min(x$lfmd)))();
      
      eval(action);
      .refit <- (loop > 0) & (i < loop);
    } 
    
    message(sprintf("Collocations fit completed after %s cycles ...", i));
    
    # Return the updated object:
    colloc;
  }
  
  vec_col_conform <- \(..., colorder_rules = I){
    #' Conform Vector Lengths
    #' 
    #' @param ... \code{\link[rlang]{dots-list}}: a list of matrices to conform (vectors are coerced into 1-m matrices)
    #' @param colorder_rules A function that governs how to order columns
    #' 
    #' @return A single matrix (ordered by row names) with rows being right-zero-padded as needed.
    #' 
    V <- rlang::list2(...);
    
    V <- lapply(V, \(i) if (!is.matrix(i)){ matrix(i, nrow = 1) } else { i });
    
    # Find the maximum number of columnns
    max_len <- sapply(V, ncol) |> max(na.rm = TRUE);
    
    lapply(V, \(v){
        v <- colorder_rules(v)
        ncol_diff <- max_col - ncol(v);
        
        if (ncol_diff > 0){ cbind(v, matrix(replicate(nrow(v), rep.int(0, ncol_diff)), ncol = ncol_diff)) } else { v }
      }) |>
      purrr::reduce(rbind) %>% 
      .[order(rownames(.)), ]
  }
  
  # :: Interactive Function Selection ----
  .all_funs <- ls(all.names = !TRUE) |> setdiff(c("env", "f_list", "..."));
  .preselect <- if (!rlang::is_empty(f_list)){ 
      grep(
        pattern = paste(f_list, collapse = "|")
        , x = ls(all.names = TRUE)
        , value = TRUE
        ) 
    } else { NULL }
  
  objs <- if (!auto){ 
    svDialogs::dlg_list(
      choices = ls(all.names = TRUE) |> 
          setdiff(c("env", "f_list", "...")) |>
          . => `[`(., !. == "pos_xform")
      , preselect = .preselect
      , title = "Choose one or more functions to load: "
      , multiple = TRUE
      )$res;
    } else { 
      if (rlang::is_empty(.preselect)){ .all_funs } else { .preselect }
    }
  
  if (rlang::is_empty(objs)){ return(invisible()) }
  
  spsUtil::quiet(list2env(mget(objs), envir = env))
}

nlp_custom_functions <- load_nlp_functions
