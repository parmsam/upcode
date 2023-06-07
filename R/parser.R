#' Parse R code
#'
#' @param file string a filename or URL to read expressions from
#' @param text optional character vector text to parse
#'
#' @import tibble
#' @importFrom tibble tibble
#'
#' @return tibble with parsed data
#' @export
#'
#' @examples
#' parser(text = "function(a = 1, b = 2) { \n  a + b\n}\n")
parser <- function(file = "", text = NULL) {
  # catch error
  retfun <- purrr::safely(
    parse,
    quiet = FALSE,
    otherwise = "Syntax Error Found, Identification Stopped"
  )
  ret <- retfun(file=file, text = text, keep.source = TRUE)
  if (!is.expression(ret$result)) {
    return(tibble::tibble(message = ret$result))
  }
  df <- getParseData(ret$result)
  df <- tibble::tibble(df)
  return(df)
}

#' Get used packages from parsed R code tibble
#'
#' @param parsed_tbl parsed R code tibble from from `parser()`
#'
#' @import dplyr tibble
#' @importFrom dplyr %>%
#' @importFrom dplyr count
#'
#' @return tibble with used packages from R code
#' @export
#'
#' @examples
#' get_used_functions(parser(file = "tests/testthat/ref/01-iris-count.R"))
get_used_packages <- function(parsed_tbl){
  get_used_functions(parsed_tbl) %>%
    dplyr::count(package, name = "use_count")
}

#' Get used functions from parsed R code tibble
#'
#' @param parsed_tbl parsed R code tibble from from `parser()`
#'
#' @import dplyr tibble
#' @importFrom dplyr %>%
#' @importFrom dplyr count
#'
#' @return tibble with used packages from R code
#' @export
#'
#' @examples
#' #' get_used_functions(parser(file = "tests/testthat/ref/01-iris-count.R"))
get_used_functions <- function(parsed_tbl){
  tokens <- dplyr::filter(
    parsed_tbl,
    token %in% c("SYMBOL_FUNCTION_CALL", "SPECIAL", "SYMBOL_PACKAGE")
  )
  if(nrow(tokens) == 0) {
    return (NULL)
  }
  # grouping and complete to ensure all three columns carry through after pivot
  # regardless if seen in the parsed data
  filtered_tokens <- tokens %>%
    dplyr::mutate(token = factor(token,
                          c("SYMBOL_FUNCTION_CALL", "SPECIAL", "SYMBOL_PACKAGE"))) %>%
    dplyr::group_by(line1, parent) %>%
    tidyr::complete(token = token)

  wide_tokens <- tidyr::pivot_wider(filtered_tokens,
                             id_cols = c(line1, parent),
                             values_from = text,
                             names_from = token) %>%
    dplyr::ungroup()

  combine_tokens <- wide_tokens %>%
    dplyr::mutate(
      function_name = dplyr::coalesce(SYMBOL_FUNCTION_CALL, SPECIAL)
    )

  get_package(combine_tokens) %>%
    dplyr::select(function_name, package) %>%
    dplyr::distinct()
}

get_package <- function(df){
  functions_only <- function(.x){
    intersect(ls(.x), lsf.str(.x))
  }
  # do not search CheckExEnv, this is created while examples are executed
  # during build
  # T and F are given a delayedAssign within the CheckExEnv environment,
  # and when we check this environments objects, the promise for T and F
  # are evaluated, and return:
  # stop("T used instead of TRUE"), stop("F used instead of FALSE")
  search_environ <- search()[search() != "CheckExEnv"]

  search_lookup <- purrr::map(search_environ, functions_only)
  names(search_lookup) <- search_environ
  df$package <- unlist(
    purrr::map(df$function_name, ~get_first(., search_lookup))
  )

  df %>%
    dplyr::mutate(package = ifelse(
      !is.na(df$SYMBOL_PACKAGE),
      paste0("package:", df$SYMBOL_PACKAGE),
      package)
    ) %>%
    dplyr::mutate(
      package = stringr::str_remove(package, "package:")
    )
}

get_first <- function(func, search_lookup){
  flag_found <- purrr::map(search_lookup, ~ func %in% .)
  if (any(unlist(flag_found))) {
    names(flag_found[flag_found == TRUE][1])
  } else {
    NA
  }
}
