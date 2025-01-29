split_n <- function(x, len) {
    i <- seq_along(x) - 1
    split(x, floor(i / len))
}

cache_id <- function() {
  opt <- getOption("cwi.cache_id", default = NULL)
  if (is.null(opt)) {
    "cwi"
  } else {
    opt
  }
}

prep_cache <- function(id = cache_id(), cache_dir = NULL) {
  if (is.null(cache_dir)) {
    cache_dir <- rappdirs::user_cache_dir(id)
  } else {
    cache_dir <- file.path(cache_dir, id)
  }
  # cache_dir <- rappdirs::user_cache_dir(id)
  cache <- cachem::cache_disk(
    dir = cache_dir,
    max_age = 7 * 24 * 60 * 60,
    evict = "fifo"
  )
  cache
}

clear_cache <- function() {
  memoise::drop_cache(check_cb_avail)()
  memoise::drop_cache(check_qwi_avail)()
  invisible(FALSE)
}
