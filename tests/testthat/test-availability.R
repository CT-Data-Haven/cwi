test_that("check_cb_avail returns proper format", {
    avail <- check_cb_avail()
    expect_named(avail, c("vintage", "program", "survey", "title"))
    expect_setequal(avail$program, c("dec", "acs"))
})

test_that("check_qwi_avail returns proper format", {
    avail <- check_qwi_avail()
    expect_named(avail, c("state_code", "start_year", "end_year"))
})

test_that("check_cb_avail speeds up after caching", {
    withr::local_options(cwi.cache_id = "check_time")
    # clear leftovers out of cache
    clear_cache()
    t1 <- system.time(check_cb_avail())["elapsed"]
    t2 <- system.time(check_cb_avail())["elapsed"]
    expect_true(t2 < t1)
})
