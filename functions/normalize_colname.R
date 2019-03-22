#' Remove and replace some pesky characters in strings
#' @example
#' sapply(X = c('hello', 'HELLO', 'HELLO DaniEL', 'danIEL + CHEN is my name', 'Daniel &     Eric &Julia'), FUN = normalize_colname)
normalize_colname <- function(name) {
  name %>%
    stringr::str_to_lower() %>%
    stringr::str_remove_all('-|&') %>%
    stringr::str_replace_all('\\+|\\.', '_') %>%
    stringr::str_replace_all('\\s+', '_') %>%
    stringr::str_replace_all('_+', '_')
}


#' Add a delimiter between `normalize_colname`ed words that will be collapsed together
#' @example
#' create_schema_name('DemOGraphiCs', 'Not too many Fun++....ky lETT     ERS Plz')
create_schema_name <- function(..., delim = '$') {
  names <- sapply(X = c(...), FUN = normalize_colname)
  paste(names, collapse = delim)
}
