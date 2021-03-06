# make geography printout--not exported
geo_printout <- function(neighborhoods, towns, regions, counties, state, msa = FALSE, us = FALSE, new_england = FALSE) {

  out <- list(unique(neighborhoods), towns, names(regions), counties, state) %>%
    purrr::map2(c("Neighborhoods", "Towns", "Regions", "Counties", "State"), function(geo, geo_head) {
      if (!is.null(geo)) {
        if (geo_head == "Neighborhoods") {
          str1 <- paste(length(geo), "neighborhoods")
        } else {
          str1 <- paste(geo, collapse = ", ")
        }
        paste(geo_head, str1, sep = ": ")
      }
    }) %>%
    purrr::discard(function(x) is.null(x)) %>%
    as.character()
  if (msa) {
    if (new_england) {
      out <- c(out, "MSA: All in New England")
    } else {
      out <- c(out, "MSA: All in US")
    }
  }
  if (us) {
    out <- c(out, "US: Yes")
  }
  paste(out, collapse = "\n")
}
