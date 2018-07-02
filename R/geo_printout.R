# make geography printout--not exported
geo_printout <- function(neighborhoods, towns, regions, counties, state, msa, us) {

  out <- list(names(neighborhoods), towns, names(regions), counties, state) %>%
    purrr::map2(c("Neighborhoods", "Towns", "Regions", "Counties", "State"), function(geo, geo_head) {
      if (!is.null(geo)) {
        str1 <- paste(geo, collapse = ", ")
        paste(geo_head, str1, sep = ": ")
      }
    }) %>%
    purrr::discard(function(x) is.null(x)) %>%
    as.character()
  if (msa) {
    out <- c(out, "MSA: All in New England")
  }
  if (us) {
    out <- c(out, "US: Yes")
  }
  paste(out, collapse = "\n")
}
