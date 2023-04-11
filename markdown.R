# <snippet: markdown.R ~ The following creates an R source file read into markdown documents: edit as desired> ----
drop_hint <- function(..., role = "toggle", context = "all", toggleGroup = "0", class = "", toggle.text = "[explore]"){
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
#' @param toggle.text (string) Text of the created tag in the default state of being collapsed.
#'
#' @note The value of \code{toggle.text} should be found in the JQuery used to toggle \code{hint} tags

text_content <- if (...length() == 0) { "" } else { paste(..., " ", sep = "") |> htmltools::HTML() }

htmltools::span(
  role = role
  , context = context
  , toggleGroup = toggleGroup
  , class = class
  , text_content
  , htmltools::tag("hint", varArgs = list(toggleGroup = toggleGroup, toggle.text))
  ) |> htmltools::tagList();
}

make.tr <- function(i, idx = 0, ...){
#' Create HTML table rows from nested lists
#' @param i The list or row data: NL ~ {row_object ~ cell_object[1, 2, ..., m]}[1, 2, ..., n]
#' @param idx When \code{make.tr} is invoked via \code{link[purrr]{purrr}} indexed mapping functions, \code{idx} holds the current position
#' @param ... Additional key-value pairs controlling the creation of each 'td' element

.first_row <- grepl("[1]", idx);

htmltools::tags$tr(class = ifelse(idx == 1, "first", ""), purrr::imap(i, ~{
.first_col = grepl("[1]", .y);

htmltools::tags$td(class = ifelse(.first_col | .first_row, "first",""), list(...)[-...length()])
}))
}

make.img <- function(img.src, context, toggle_group, scale_factor){
#' Make Encode Images
#'
#' @param img.src (string[]) A string vector of paths to images
#' @param context (string[]) A string or string vector of contexts to use for jQuery calls: must be length 1L or the same length as \code{img.src}
#' @param toggle_group (string[]) A string or string vector of contexts to use for jQuery calls: must be length 1L or the same length as \code{img.src}
#' @param scale_factor (string[]) A string or string vector of contexts to use for jQuery calls: must be length 1L or the same length as \code{img.src}
#'
#' @return A list of HTML tag lists representing a base64-encoded image

.input <- data.table::as.data.table(img.src, context, toggle_group, scale_factor) |> as.list();

purrr::pmap(.input, ~{
.img <- magick::image_read(..1);

.img_dim <- data.table::as.data.table(magick::image_attributes(.img))[
grepl("width,height", property)
, round({ stringi::stri_split_regex(value, "[, ]", omit_empty = TRUE, simplify = TRUE) |>
as.vector() |>
as.integer() * scale_factor
})];

htmltools::tags$img(src = sprintf("data:image/png;base64,%s", magick::image_write(.img) %>%
jsonlite::base64_enc()), width = .img_dim[1], height = .img_dim[2],
context = ..2, toggleGroup = ..3)
});
}

extSrcs <- list()

drop_footnote <- function(text, id, class = "", href = NULL, reverse = FALSE){
#' Drop a Footnote
#'
#' \code{drop_footnote} creates a superscript HTML tag for use as a hyper-linked footnote
#'
#' @param text (string) The text to use as the footnote marker
#' @param id,class (string) The CSS identifier and class for the generated tag
#' @param href (string) The target URL, either external or reference to an in-document location
#' @param reverse (logical) Should the originating (\code{FALSE}) or target (\code{TRUE}) be created?
  htmltools::tags$sup(htmltools::tags$a(
    id      = sprintf("#%s%s", id, ifelse(reverse, "_target", ""))
    , href  = ifelse(rlang::is_empty(href), sprintf("#%s%s", id, ifelse(!reverse, "_target", "")), href)
    , target= ifelse(rlang::is_empty(href), "_self", "_blank")
    , class = class, text)
    ) |>
    as.character() |>
    htmltools::HTML()
}
# </snippet>
