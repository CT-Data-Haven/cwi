.onLoad <- function(libname, pkgname) {
  cache <- prep_cache(id = cache_id(), cache_dir = NULL)
  check_cb_avail <<- memoise::memoise(check_cb_avail, cache = cache)
  check_qwi_avail <<- memoise::memoise(check_qwi_avail, cache = cache)
}
