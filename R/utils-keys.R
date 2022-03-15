check_census_key <- function(key) {
  check_key(key, "CENSUS_API_KEY")
}

check_bls_key <- function(key) {
  check_key(key, "BLS_KEY")
}

check_key <- function(key, var) {
  if (is.null(key)) {
    key <- Sys.getenv(var)
  }
  if (nchar(key) == 0) {
    return(FALSE)
  } else {
    return(key)
  }
}
