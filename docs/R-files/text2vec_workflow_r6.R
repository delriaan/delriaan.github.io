assertive::assert_all_are_true(c(
  # Required Libraries:
  require(magrittr)
  , require(purrr)
  , require(data.table)
  , require(text2vec)
  , require(stringi)
  , require(textclean)
  , require(lexicon)
  , require(udpipe)
  , require(tictoc)
  , require(igraph)
  ))

# Public and active objects are initially saved in separate environments:
.public <- new.env();
.public %$% {
  dataset <- tfidf_mdl <- tf_idf <- NULL;
  
  version <- format(Sys.time(), "%Y%m%d-%H%M%S");
  
  workflow.steps <- "$make.vocab()$make.dtm()$make.tfidf()$make.tcm()$make.topics()$make.vectors()$make.dvm()"
  
  make.vocab <- \(it = self$token.iter, vectorizer = self$t2v.vectorizer, voc = self$vocab, prune = FALSE, ...){
		#' Create the Vocabulary
		#' 
	  #' @param it An optional pre-processed token iterable
	  #' @param vectorizer An optional, pre-derived vectorizer
		#' @param voc An optional vocabulary
		#' @param prune (logical) Should the vocabulary be pruned?
		#' @param ... \code{\link[rlang]{dots_list}} See \code{\link[text2vec]{itoken}} and \code{\link[text2vec]{create_vocabulary}}. Arguments \code{iterable}, \code{it}, and \code{stopwords} are internally supplied from user-defined parameters
		#' @return The class object invisibly
		
		  # ~ Create the Token Iterator ====
		  tictoc::tic("... creating the token iterable ...");
		  if (rlang::is_empty(it)){
        fun <- text2vec::itoken
        if (!rlang::is_empty(osVersion |> grep(pattern = "Linux"))){
          fun <- text2vec::itoken_parallel
        }
        
		    it <- fun(
	        iterable = self$dataset[[private$dataset_doc_col]]
	        , ids = self$dataset[[private$dataset_rec_idx]]
	        , ...
	        );
		  }
	  
		  tictoc::toc(log = TRUE);
			
			# ~ Create Vocabulary & vectorizer ====
		  tictoc::tic("... creating vocabulary ...");
		  
			if (rlang::is_empty(voc)){
				voc <- do.call(text2vec::create_vocabulary, args = list(it = it, stopwords = private$stop_words));
			}
			
		  if (prune){
		    voc <- do.call(text2vec::prune_vocabulary
		                   , args = rlang::list2(!!!private$glove_params$vocab_params, vocabulary = voc));
		  }
		  
		  if (rlang::is_empty(vectorizer)){ vectorizer <- text2vec::vocab_vectorizer(voc) } 
		  
      assign("token.iter", it, envir = self);
	    assign("vocab", voc, envir = self);
	    assign("t2v.vectorizer", vectorizer, envir = self);
			
      if ("tokenizer" %in% names(list(...))){
        assign("tokenizer", list(...)$tokenizer, envir = private);
      } else {
        assign(
          "tokenizer"
          , eval(rlang::parse_expr(sprintf("text2vec::%s", formals(text2vec:::itoken.character)$tokenizer |> as.character())))
          , envir = private
          );
      }
      tictoc::toc(log = TRUE);
			
			# ~ Return ====
			invisible(self);
	}
  
  make.tcm <- \(it = self$token.iter, vectorizer = self$t2v.vectorizer, ...){
		#' Create Term Co-occurrence Matrix
		#' 
		#' Create a term co-occurrence matrix.
		#' 
	  #' @param it An optional pre-processed token iterable
	  #' @param vectorizer An optional pre-derived vectorizer
		#' 
		#' @param ... \code{\link[rlang]{dots_list}} See \code{\link[text2vec]{create_tcm}} excluding arguments \code{it} and \code{vectorizer}
	    tictoc::tic("... creating TCM ...");
	  
	    list2env(rlang::list2(...), envir = environment());
	    args <- mget(ls());
	    
	    tcm <- do.call(text2vec::create_tcm, args = args);
		  assign("tcm", tcm, envir = self);
	    tictoc::toc(log = TRUE);
		  
		  # ~ Return ====
		  invisible(self);
	}
  
  make.dtm <- \(it = self$token.iter, vectorizer = self$t2v.vectorizer, type = "TsparseMatrix", ...){
	  #' Create Document-Term Matrix
	  #' 
	  #' Create a document-term matrix via \code{\link[text2vec]{create_dtm.}}. 
	  #' 
	  #' @note This function is found in \code{text2vec_workflow} and \code{topic_model.learn} and should be kept in sync.
	  #' 
	  #' @param it See \code{\link[text2vec]{create_dtm}}
	  #' @param vectorizer A vectorizer (see \code{\link[text2vec]{create_dtm}})
	  #' @param type See \code{\link[text2vec]{create_dtm}}
		  tictoc::tic("... creating DTM ...");
		  self$dtm <- cbind(
		        "[UNK]" = rep.int(0, dim(self$dataset)[1])
	          , do.call(text2vec::create_dtm, args = list(it = it, type = type, vectorizer = vectorizer))
		        );
		  
		  tictoc::toc(log = TRUE);
		  
		  # ~ Return ====
		  invisible(self);
		}
  
  make.tfidf <- \(dtm = self$dtm, type = "TsparseMatrix", predict_context = FALSE, export = FALSE, ...){
	  #' Create Term-Frequency-Inverse-Document-Frequency Matrix
	  #' 
	  #' Create a document term matrix normalized as TFIDF via \code{\link[text2vec]{TfIdf}}. 
	  #' 
	  #' @note This function is found in \code{text2vec_workflow} and \code{topic_model.learn} and should be kept in sync.
	  #' 
	  #' @param dtm A document-term-matrix (See \code{\link[text2vec]{create_dtm}})
    #' @param type See \code{\link[text2vec]{create_dtm}}
    #' @param predict_context (logical) Should the TFIDF be created for the prediction context?
    #' @param ... See \code{\link[text2vec]{TfIdf}}
      tictoc::tic("... creating TfIdf ...");
      if (!predict_context){
        assign("tfidf_mdl", text2vec::TfIdf$new(...), envir = self);
        res <- self$tfidf_mdl$fit_transform(dtm);
      } else {
        res <- self$tfidf_mdl$transform(dtm);
      }
    
      if (export){
        res
      } else { 
        assign(c("tf_idf", "tf_idf_predict")[1 + predict_context], res, envir = self); 
        invisible(self);
      }
		  tictoc::toc(log = TRUE);
		  
		  # ~ Return ====
		  invisible(self);
		}
  
  make.dvm <- \(dtm = c("tf_idf_predict", "tf_idf", "dtm"), vec = self$word_vectors, tokenizer = private$tokenizer, export = FALSE){
	  #' Create Document-Vector Matrix
	  #' 
	  #' Create a document-vector matrix from class members \code{dtm}, \code{tcm}, and \code{word_vectors}. The result is an object of class \code{dvm} with slots \code{dvm} and \code{vocabulary}.
	  #' 
	  #' @param dtm A document-term matrix or vector of text to be turned into a document-term matrix.
	  #' @param vec A word vector matrix.
	  #' @param tokenizer A tokenizer function (must return a list).
	  #' @param export (logical) Should the DVM be exported for assignment to the workspace?
	  #' 
	  #' @return The class object invisibly.

      # Select the type of DTM to use (the same call is found the class method 'make.topics()'):
      dtm <- get(match.arg(dtm, choices = ls(self, sorted = FALSE), several.ok = TRUE)[1], envir = self);
      
      if (is.character(dtm)){
        dtm <- self[[names(self)[match(dtm, names(self), nomatch = 3) %>% .[1]]]];
      }
    
		  tictoc::tic("... creating DVM ...");
		  
      if (is.character(dtm)){
        force(tokenizer);
        dtm <- self$vector_eyes(dtm, voc = colnames(self$dtm), tokenizer = tokenizer) |> as(class(self$dtm));
      } else if (!any(class(dtm) %in% class(self$dtm))){
        dtm <- as(dtm, class(self$dtm));
      }
	    
	    # Create the DVM and add the vocabulary as an attribute:
	    .dvm_class <- setClass("dvm", slots = c(vectors = "ANY", vocabulary = "character"));
	    
	    res <- .dvm_class(vectors = dtm %*% vec, vocabulary = rownames(vec));
	    
		  tictoc::toc(log = TRUE);
	    
	    if (export){ 
	      res
	    } else { 
	      assign("dvm", res, envir = self); 
  		  invisible(self);
	    }
		}
  
  make.vectors <- \(){
	  #' Create Global Vectors
	  #' 
	  #' \code{$make.vectors} creates global vectors that incorporate term-co-occurrence.
	  #' 
	  #' @param fun A combiner function for main and context matrices. If a custom function is provided, arguments \code{wv_m} (main) and \code{wv_c} (context) are required and must return output the same dimension as \code{wv_m}.
	  #' 
	  #' @return The class object invisibly.
		
		  # ~ GloVe ====
		  fun <- function(wv_m, wv_c = self$glove$components){ wv_m + t(wv_c) }
			tictoc::tic("... creating global vectors ...");
			self$glove <- do.call(text2vec::GlobalVectors$new, private$glove_params$glove_vec_params)
			tictoc::toc(log = TRUE); 
			
			# ~ GloVe fit ====
			tictoc::tic("... fitting GloVe ...");
			
			assign("word_vec.main", { 
			  do.call(self$glove$fit_transform
			  , rlang::list2(x = self$tcm, !!!private$glove_params$glove_fit_params))
			 }, envir = self);
			
			wv <- rbind(
  			  array(0, dim = c(1, ncol(self$word_vec.main)), dimnames = list("[UNK]", NULL))
  			  , fun(wv_m = self$word_vec.main, wv_c = self$glove$components)
    			);
			
			assign("word_vectors", wv, envir = self);
			
			tictoc::toc(log = TRUE); 
			
			# ~ Return ====
			invisible(self);
		}
  
  make.topics <- \(dtm = c("tf_idf_predict", "tf_idf", "dtm"), tokenizer = private$tokenizer, predict_context = FALSE, export = FALSE){
    #' Fit the LDA Topic Model
    #' 
    #' Create an LDA topic matrix from class member \code{dtm}.
    #' 
    #' @param dtm One of the following:\cr\itemize{\item{A document-term matrix} \item{A TF-IDF matrix} \item{A vector of text to be turned into a document-term matrix}}
    #' @param tokenizer A tokenizer function (must return a list).
    #' @param predict_context (logical) Should the existing LDA model be used for predictions?
    #' @param export (logical) Should the document-topic matrix be exported for assignment to the workspace?
    #' 
    #' @return The class object invisibly.
    
    # LDA ====
    if (!predict_context){
      tictoc::tic("... creating LDA model ...");
      self$lda_mdl <- do.call(text2vec::LDA$new, private$topic_params$lda_params)
      tictoc::toc(log = TRUE); 
    }
    
    # Select the type of DTM to use (the same call is found the class method 'make.dvm()'):
    dtm <- get(match.arg(dtm, choices = ls(self, sorted = FALSE), several.ok = TRUE)[1], envir = self);
    
    # Fit (or predict with) the LDA model ====
    tictoc::tic("... calculating LDA topic distribution ...")
    if (is.character(dtm)){
        force(tokenizer)
        dtm <- self$vector_eyes(dtm, voc = colnames(self$dtm), tokenizer = tokenizer) |> as(class(self$dtm));
      } else if (!any(class(dtm) %in% class(self$dtm))){
        dtm <- as(dtm, class(self$dtm));
      }
    
    res <- rlang::exprs(
      self$lda_mdl$fit_transform(x = dtm, !!!private$topic_params$lda_fit_params)
      , self$lda_mdl$transform(x = dtm)
      )[[1 + predict_context]];
      
    res %<>% eval();
    
    tictoc::toc(log = TRUE); 
    
    # Assign results ====
    if (export){ 
      res
    } else { 
      assign(c("topics", "topics_predict")[1 + predict_context], res, envir = self);
      invisible(self);
    }
  }
  
  vector_eyes <- \(docs, voc = self$vocab$term, tokenizer = private$tokenizer, sparse = TRUE){
    #' Create a Document-Term Matrix
    #' 
    #' @param docs A list containing text to vectorize.
    #' @param dtm A document-term matrix or vector of text to be turned into a document-term matrix.
    #' @param tokenizer A tokenizer function (must return a list, one per document).
    #' @param sparse (logical) Should the output be a sparse matrix of class "TsparseMatrix"?
    #' 
    #' @return A document-term matrix. 
    #' 
    #' @note This function returns an object and therefore is not pipe-enabled.
    # browser()
    
    force(tokenizer);
    force(voc)
    
    res <- tokenizer(docs) |>
      purrr::map(\(.tokens){
        token_counts <- table(.tokens);
        voc_matches <- matrix(voc %in% names(token_counts), nrow = 1);
        voc_freqs <- colSums(as.matrix(token_counts) %*% voc_matches);
        array(voc_freqs, dim = c(1, length(voc)), dimnames = list(NULL, voc))
      }) |> 
      purrr::reduce(rbind) |>
      as("TsparseMatrix")
    
    if (!sparse){
      return(as.matrix(res))
    } else {
      return(res)
    }
  }
  
  get.private <- \(..., list.only = TRUE){ 
	  #' Return a member from \code{$private}
	  #' 
	  #' @param ... (string[]) Atomic strings indicating which elements in (list)i to retrieve 
	  #' @param list.only (logical) Only list the names of objects found.
	  
    haystack <- ls(envir = private, all.names = TRUE);
    needle <- if (missing(...)){ haystack } else { unlist(rlang::list2(...), use.names = FALSE)}
	  res <- intersect(haystack, needle);
	  
	  if (list.only){ 
	    print(res); 
	    invisible(self); 
	  } else { 
	    if (rlang::is_empty(res)){ stop("No matching elements found ...") }
	    mget(res, envir = private)
	   }
	}
  
  set.private <- \(...){
	  #' Update a member in \code{$private}
	  #' 
	  #' @param ... (key<value>) Key-value pairs (\code{key1 = value1, key2 = value2, ...}) to update or add/remove
	  #' @details For each key found in \code{$private[[i]]}, the value is updated if it exists or added if not. Setting a value to NULL removes it from the list. 
	  #' @return The class object invisibly
		  
		  .vals <- rlang::dots_list(..., .named = TRUE, .ignore_empty = "all", .homonyms = "last");
		  if (rlang::is_empty(.vals)){ stop("No key-value pairs found ...") }
		  
		  .rem <- purrr::keep(.vals, is.null) |> names();
		  
		  .haystack <- ls(envir = private, all.names = TRUE);
		  
		  if (!rlang::is_empty(.rem)){ 
		    .rem <- intersect(.haystack, .rem) ;
		    rm(list = .rem, envir = private)
		  }
		  .upd <- intersect(.haystack, names(.vals)[!names(.vals) %in% .rem]);
		  .add <- names(.vals)[!names(.vals) %in% c(.upd, .rem)];
		  
		  list2env(.vals[c(.upd, .add)], envir = private);
		  message(glue::glue("Processed {length(.vals)} elements: {length(.upd)} updated, {length(.add)} added, {length(.rem)} removed ..."));
		  
		  invisible(self); 
  }
  
  set.dataset <- \(doc){
    #' Set/Replace the dataset
    #' 
    #' \code{$set.dataset()} replaces an existing dataset with a new one. If calling 
    #' this method from a cloned object, the new dataset will inherit the previous
    #' column names for the document and record index columns. If not, use method 
    #' \code{$set.private(dataset_doc_col = "doc", dataset_rec_idx = "idx")} to set.
    #' 
    #' @param doc A character vector of documents
    #' 
    #' @return The class object invisibly
    
    self$dataset <- data.table::data.table(doc, idx = seq_along(doc)) |> 
      data.table::setnames(c(private$dataset_doc_col, private$dataset_rec_idx));
    
    invisible(self)
  }
  
  upgrade <- \(obj){
    #' Transfer Class Objects to New Instance
    #' 
    #' This function will make a deep copy of an existing \code{text2vec_workflow} object and transfer the contents to a new instance with upgraded features.
    #' 
    #' @param obj An object of class \code{text2vec_workflow}
    #' 
    #' @return An modified object of class \code{text2vec_workflow}
    temp <- new.env()
    
    temp$private <- obj$.__enclos_env__$private
    temp$version <- format(Sys.time(), "%Y%m%d-%H%M%S");
    
    ls(pattern = "^(dataset|tcm|dtm|dvm|topic|vocab|word_vectors|glove|t2v[.]vectorizer|token.iter|lda|tf)", envir = obj) |>
      mget(envir = obj) |>
      list2env(envir = temp)
    
    out <- text2vec_workflow$new(
      dataset = obj$dataset
      , dataset_doc_col = !!(temp$private$dataset_doc_col |> rlang::sym())
      , dataset_rec_idx = !!(temp$private$dataset_rec_idx |> rlang::sym())
      , dataset_dt_key = !!(temp$private$dataset_dt_key |> rlang::sym())
      , no_stem = temp$private$no_stem 
      , stop_words = temp$private$stop_words 
      , glove_params = temp$private$glove_params 
      , topic_params = temp$private$topic_params 
      , predict = temp$private$predict 
      );
    
    out$set.private(!!!mget(ls(envir = temp$private), envir = temp$private))
    
    temp %$%
      mget(ls() |> purrr::discard(\(x) x == "private")) |> list2env(out)
    
    return(out)
  }
  
  initialize <- \(dataset, dataset_rec_idx, dataset_doc_col, dataset_dt_key
    , glove_params, topic_params, stop_words = stopwords::stopwords()
    , no_stem = TRUE, ...){
		#' Class Constructor
		#' 
		#' @section \code{glove_params}:
		#' \code{glove_params} should be a nested list with member lists defined as follows:
		#' \itemize{
		#' \item{vocab_params: doc_proportion_max, doc_proportion_min, term_count_min}
		#' \item{glove_vec_params: rank, x_max}
		#' \item{glove_fit_params: n_iter = 1000, convergence_tol, n_check_convergence}
		#' }
    #' 
    #' @section \code{topics_params}: 
    #' \code{topics_params} should be a nested list with member lists defined as follows:
    #' \itemize{
    #' \item{vocab_params: doc_proportion_max, doc_proportion_min, term_count_min}
    #' \item{lda_params: n_topics, n_iter, doc_topic_prior, topic_word_prior}
    #' \item{lda_fit_params: n_iter = 1000, convergence_tol, n_check_convergence}
    #' }
		#'   
		#' @param dataset The dataset to use
		#' @param dataset_rec_idx (string) String literal indicating the name of the indexing column to create in dataset
		#' @param dataset_doc_col (string) String literal indicating the column in dataset holding the text to model
		#' @param dataset_dt_key (string[]) A string vector containing the columns in dataset participating in the key
		#' @param glove_params,topic_params (list) A list holding context-relevant modeling parameters.  See 'Details' for more information.
		#' @param stop_words (string[]) A string vector of stopwords
		#' @param no_stem (logical) Ignore stemming?
		#' @param ... (key<value>) Key-value pairs (\code{key1 = value1, key2 = value2, ...}) to include in the \code{private} environment
		#' 
		#' @return An R6 object 
		
			if (!data.table::is.data.table(dataset)){ data.table::setDT(dataset) }
	  
	    dataset_rec_idx <- rlang::enexpr(dataset_rec_idx) |> as.character();
	    dataset_doc_col <- rlang::enexpr(dataset_doc_col) |> as.character();
	    dataset_dt_key <- rlang::enexpr(dataset_dt_key) |> as.character();
	  
			self$dataset <- data.table::setkeyv(dataset, dataset_dt_key);
	    
	    tictoc::toc(log = TRUE);
			set.seed(Sys.time());
			
			rlang::list2(
				dataset_rec_idx = dataset_rec_idx
				, dataset_doc_col = dataset_doc_col
				, dataset_dt_key = dataset_dt_key
				, preprocessor = identity
				, no_stem = no_stem
				, stop_words = stop_words
				, glove_params = glove_params
				, topic_params = topic_params
				, ...
				) |> list2env(envir = private);
	    
	    invisible(self);
  	}
  
  export <- \(){
      #' Export objects from the class environment
      out <- self$clone(deep = TRUE);
      out$dataset <- out$tf_idf <- NULL;
      out$workflow.steps <- "$make.vocab()$make.dtm()$make.tfidf(predict_context = TRUE)$make.tcm()$make.topics(predict_context = TRUE)$make.dvm()"
      rm(token.iter, dtm, tcm, vocab, dvm, topics, perplexity, make.vectors, envir = out)
      return(out);
    }
	
  reference <- function(){
    #' text2vec Reference
    #' 
    #' \code{$reference()} will open a browser window to the \code{text2vec} documentation page
    browseURL("https://text2vec.org") 
  }
  
	perplexity <- function(
    predict_context = FALSE
    , dtm = c("tf_idf_predict", "tf_idf", "dtm")
    , topic_word_distribution = self$lda_mdl$topic_word_distribution
    , doc_topic_distribution = self[[c("topics", "topics_predict")[1 + predict_context]]]
    ){
      #' Topic Perplexity
      #' 
      #' @param X,topic_word_distribution,doc_topic_distribution See \code{\link[text2vec]{perplexity}}
      #' 
      #' @return Invisibly, the perplexity value.
      assertive::assert_any_are_true(c("dtm", "tf_idf", "lda_mdl", "lda_topic_distr") %in% ls(self));
    
      # Select the type of DTM to use (the same call is found the class method 'make.dvm()'):
      dtm <- get(match.arg(dtm, choices = ls(self, sorted = FALSE), several.ok = TRUE)[1], envir = self);
      
      perplexity <- text2vec::perplexity(X = dtm, topic_word_distribution = topic_word_distribution, doc_topic_distribution = doc_topic_distribution);
      cli::cli_alert_info("Perplexity: {perplexity}");
      return(invisible(perplexity))
    }
  
	help <- \(i){
		#' Help Me Out!
		#' 
		#' \code{$help} will generate help documentation or text related to this class using \code{\link[docstring]{docstring}}
		#' 
		#' @param i The name of a method or field
		#' 
		#' @return Invisibly, the class environment
		
    if (missing(i)){
      i <- svDialogs::dlg_list(
        title = "Choose a function to view documentation"
        , choices = text2vec_workflow$public_methods |> names()
        , rstudio = FALSE
        )$res
    } else {
      i <- rlang::enexpr(i) |> rlang::as_label();
    }
		
		if (purrr::is_function(text2vec_workflow$public_methods[[i]])){ 
				assign(i, text2vec_workflow$public_methods[[i]]);
				rlang::expr(docstring::docstring(!!as.name(i))) |> eval()
		} else { 
		  cat(c(workflow.steps = "A string with the typical workflow represented")[i]) 
		}
	  
		invisible(self);
	}
 }
	
.active <- new.env();
.active %$% {
  tokenizer <- function(){ self$get.private("tokenizer", list.only = FALSE) %>% .[[1]] }
  
  text2vec_hompage <- function(browser = NULL){ browseURL("https://text2vec.org/index.html", browser = browser) }
}

# Define the class with pre-defined objects:
text2vec_workflow <- R6::R6Class(
  classname = "text2vec_workflow"
  , lock_objects = FALSE
  , public = .public %$% mget(ls())
  , private = list(.init = NULL)
  , active = .active %$% mget(ls())
  );

# Define default parameter sets for GloVe and topic-modeling:
text2vec_params <- { list(
  glove = { list(
      vocab_params = list(
          doc_proportion_max = 0.9
          , doc_proportion_min = 0.1
          , term_count_min = 5
          )
      , glove_vec_params = list(
          rank = 50
          , x_max = 10
          )
      , glove_fit_params = list(
          n_iter = 1000
          , convergence_tol = 0.01
          , n_check_convergence = 10
          )
      ) |> 
      magrittr::set_attr("comment", "https://text2vec.org/glove.html")
    }
  , topics = { list(
      vocab_params = list(
          doc_proportion_max = 0.9
          , doc_proportion_min = 0.1
          , term_count_min = 5
          )
      , lda_params = list(
          n_topics = 10
          , n_iter = 1000
          , doc_topic_prior = 0.1
          , topic_word_prior = 0.1
          )
      , lda_fit_params = list(
          n_iter = 1000
          , convergence_tol = 0.01
          , n_check_convergence = 10
          )
      ) |> 
      magrittr::set_attr("comment", "https://text2vec.org/topic_modeling.html")
    }
  )}

# Clean Up:
rm(.public, .active)
gc()

concept_graph <- \(root_token, max_iter = 2L, top_n = 3L, sim_threshold = 0.1, object, chatty = FALSE){
  #' Create a Concept Graph
  #' 
  #' This function creates a \emph{"concept graph"} from a vector space and is the result of a recursive search for the most similar tokens to a given root token constrained by a set of thresholds.
  #' 
  #' @param root_token (string) The root token from which to begin the recursive search
  #' @param max_iter (number) The maximum number of iterations to perform
  #' @param top_n (number) The top N most similar tokens to return
  #' @param sim_threshold (number) The similarity threshold to use in the range (0, 1]
  #' @param object An object of class \code{text2vec_workflow}
  #' @param chatty (logical) Should the function return execution messages?
  #' 
  #' @return A list containing the graph, the visualization, the recursion output, and the first four arguments of the function
  
  force(n)
  force(sim_threshold)
  
  # Argument assertions:
  assertive::assert_all_are_true(c(
    length(sim_threshold) %in% c(1,2)
    , all(is.numeric(sim_threshold))
    , ifelse(length(sim_threshold) == 2, all(sign(sim_threshold) %in% c(-1, 1)), TRUE)
    , is.numeric(top_n) || is.integer(n)
    , length(n) == 1
    , top_n > 0
    ))
  
  assertive::assert_is_identical_to_true(is(object, "text2vec_workflow"))
  
  # Force sim_threshold to be a monotonically increasing numeric vector:
  sim_threshold <- sort(sim_threshold)
  
  # Define the recursive function:
  recurse <- \(token){
    #| `token`: The input vector of tokens
    #| Returns a named vector of cosine similarity scores or an empty vector.
    
    # Ensure the token is in the vector space:
    token <- intersect(token, rownames(object$word_vectors)) |> unique()
    
    # assertion check for empty value:
    assertive::assert_any_are_true(length(token) > 0)
    
    v1 <- object$word_vectors[token, , drop = FALSE]
    
    # Calculate the similarity of vectors not in `v1` using the cosine similarity method:
    z <- text2vec::sim2(v1, object$word_vectors[!rownames(object$word_vectors) %in% token, , drop = FALSE])
    
    # Derive the result: note the use of argument 'simplify' which forces a list output:
    res <- apply(z, 1, \(current_scores){
        # Check for the case where all values are less than the threshold:
        if (all(abs(current_scores) < max(sim_threshold))){
          if (chatty) cli::cli_alert_warning("All (absolute) values less than the maximum threshold of {max(sim_threshold)} (max value: {max(current_scores, na.rm = TRUE)})")
          return(numeric())
        }
      
        # `i` is a scalar index:
        i <- if (length(sim_threshold) == 1){
                # The default check for similarity above or equal to the threshold:
                current_scores >= sim_threshold
              } else {
                # The following checks for values (dis)similarity at or beyond the thresholds:
                current_scores >= sim_threshold[2] | current_scores <= sim_threshold[1]
              }
        
        # Subset then reverse order by absolute value:
        current_scores <- current_scores[i] |>. => .[order(abs(.), decreasing = TRUE)]
        
        if (length(current_scores) < top_n){
         if (chatty)  cli::cli_warn("Result set of length {length(current_scores)}L less than requested length ({top_n}L)")
        }
        
        # Return (if the call to na.omit() results in an empty value, recursion will stop).
        if (hasName(attributes(token), "scores")){
          if (any(token %in% names(current_scores))){
            current_scores[token] <- attr(token, "scores")[token] + current_scores[token]
          }
        }
        
        current_scores[1:min(length(current_scores), top_n)] |> na.omit()
      }, simplify = FALSE) |>
      purrr::compact() |>
      purrr::flatten()
    
    return(res)
  }
  
  # Call the recursive function:
  output <- book.of.utilities::call.recursion(
    root_token
    , fun = recurse
    , test = \(x) !identical(x, list())
    , nxt = \(x){ magrittr::set_attr(names(x), "scores", x) }
    , simplify = TRUE
    , max.iter = max_iter
    ) |>
    purrr::flatten()
  
  # `token_weights` is a vector of mean token similarity scores over the history of recursive calls:
  token_weights <- split(output, f = names(output)) |> 
    purrr::map_dbl(\(o){ o <- unlist(o); weighted.mean(o, w = seq_along(o)) })

  # Create the concept graph:
  viz_graph <- output |> 
    names() |> 
    slider::slide(.after = 1L, .step = 2L, .f = \(x) list(tk1 = x[1], tk2 = x[2])) |> 
    purrr::compact() |> 
    data.table::rbindlist() |> 
    unique() |>
    igraph::graph_from_data_frame() |> 
    (\(g){
     igraph::V(g)$title <- igraph::V(g)$name
     w <- exp(token_weights[igraph::V(g)$name]) |>
      purrr::modify_if(\(x) is.na(x) | is.nan(x), ~0.01)
     
     igraph::V(g)$prank <- igraph::page_rank(g, personalized = w)$vector
     igraph::V(g)$mass <- 50 * book.of.utilities::ratio(object$tf_idf[, igraph::V(g)$name, drop = FALSE] |> apply(2, sum, na.rm = TRUE), of.max)
     igraph::V(g)$size <- igraph::degree(g, mode = "in") + igraph::V(g)$mass
     
     # Vertex colors defined as follows:
     # - degree "in" = 0 "#333"
     # - degree quantile [0.25, 0.50]: "#A55"
     # - degree quantile [0.51, 0.75]: "#5A5"
     # - degree quantile [0.75, 1.00]: "#55A"
     .colors <- igraph::degree(g, mode = "in") |> 
       (`*`)(10) |>
       as.numeric() |>
       book.of.features::make.quantiles(
         c(0.00, 0.25, 0.50, 0.75, 1.0)
         , names = TRUE
         , as.factor = TRUE
         )
     
     igraph::V(g)$group <- paste(igraph::V(g)$title, .colors, sep = ",")
     
     igraph::V(g)$color <- ifelse(
        igraph::V(g)$title == root_token
        , "#FF33FFFF"
        , c(`0%` = "#33333355", `25%` = "#CDECDE99", `50%` = "#5CAC5CAA", `75%` = "#5C5CACCC", `100%` = "#0C0CFCCC")[as.character(.colors)]
        ) |> 
       unname() |> 
       as.list()
     
     comment(g) <- glue::glue(
      .sep = "\n"
      , "Mass is defined as a function of token-weighted page rank."
      , "Size is defined as a function of 'in'-degree and mass."
      , "Color is defined as a function of 'in'-degree quantiles."
      )
     
     return(g)
  })()
 
  # Visualize the graph:
  out_title <- glue::glue(
    "Root token: {paste(root_token, collapse = '::')}"
    , "Max iterations: {max_iter}"
    , "Top N: {top_n}"
    , "Similarity threshold: {paste(sim_threshold, collapse = \", \")}"
    , .sep = " | "
    )
  
  graph_viz <- viz_graph |>
    visNetwork::visIgraph(physics = TRUE) |>
      visNetwork::visLayout(improvedLayout = TRUE) |>
      visNetwork::visPhysics(
        solver = "barnesHut"
        , barnesHut = list(
            centralGravity = 0.05
            , gravitationalConstant = -300
            , springLength = 150
            , springConstant = 0.1
            , damping = 0.5
            , avoidOverlap = 0.8
            )
        , timestep = 0.1
        ) |>
      visNetwork::visOptions(
        width = 2180
        , height = 1440
        , collapse = TRUE
        , selectedBy = list(variable = "group", multiple = TRUE)
        ) |>
        htmlwidgets::prependContent(htmltools::tags$h2(out_title))
  
  # Return the graph, the visualization, the recursion output, and the first four arguments of function `concept_graph()`:
  mget(c(
    "root_token"
    , "token_weights"
    , "output"
    , "viz_graph"
    , "graph_viz"
    )) |>
    append(list(params = mget(c("max_iter", "top_n", "sim_threshold"))))
}
