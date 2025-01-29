test_that("split_n returns list of proper length", {
  len1 <- 10
  len2 <- 5
  x1 <- split_n(1:25, len1)
  x2 <- split_n(1:25, len2)
  expect_length(x1, 3)
  expect_length(x2, 5)
  expect_length(x1[[1]], len1)
  expect_length(x2[[1]], len2)
})

test_that("cache_id gets id from user options", {
  tmp <- tempdir()
  withr::local_options(cwi.cache_id = NULL)
  id1 <- cache_id()
  expect_equal(id1, "cwi")

  withr::local_options(cwi.cache_id = "check_id")
  id2 <- cache_id()
  expect_equal(id2, "check_id")
})

test_that("prep_cache returns expected cachem obj", {
  tmp <- tempdir()
  cache <- prep_cache(id = "check_class", cache_dir = tmp)
  expect_s3_class(cache, "cache_disk")
})

test_that("prep_cache inherits cache id", {
  tmp <- tempdir()
  withr::local_options(cwi.cache_id = "check_opt")
  cache1 <- prep_cache(cache_dir = tmp)
  expect_true(grepl("check_opt", cache1$info()$dir))

  # if opt = NULL, set to cwi
  withr::local_options(cwi.cache_id = NULL)
  cache2 <- prep_cache(cache_dir = tmp)
  expect_true(grepl("cwi", cache2$info()$dir))
})

test_that("clear_cache clears cache", {
  withr::local_options(cwi.cache_id = "check_clear")
  check_cb_avail()
  expect_true(memoise::has_cache(check_cb_avail)())

  clear_cache()
  expect_false(memoise::has_cache(check_cb_avail)())
})
