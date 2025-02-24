# test_that("sub_nonanswers handles factors", {
#     xt1 <- cws_demo
#     xt2 <- dplyr::mutate(xt1, response = as.factor(response))
#     expect_type(sub_nonanswers(xt1, factor_response = TRUE)$response, "integer")
#     expect_type(sub_nonanswers(xt1, factor_response = FALSE)$response, "character")
#
#     expect_type(sub_nonanswers(xt2, factor_response = TRUE)$response, "integer")
#     expect_type(sub_nonanswers(xt2, factor_response = FALSE)$response, "character")
#
#     xt_sub <- sub_nonanswers(xt1)
#     expect_equal(levels(xt_sub$response), c("Yes", "No"))
# })
#
# test_that("sub_nonanswers handles nons", {
#     xt <- read_xtabs(demo_xt(2018), year = 2018, process = TRUE)
#     xt <- dplyr::filter(xt, code == "Q4A")
#     expect_silent(sub_nonanswers(xt, nons = c("Don't know enough about it in order to say", "Refused")))
#     expect_warning(sub_nonanswers(xt), "not found")
#     expect_warning(sub_nonanswers(xt, nons = c("X", "Y")))
# })
#
# test_that("sub_nonanswers handles values above 1.0", {
#     xt <- read_xtabs(demo_xt(2018), year = 2018, process = TRUE)
#     xt <- dplyr::filter(xt, code == "Q1")
#     xt$value[1] <- 1.1
#     expect_warning(sub_nonanswers(xt))
# })
#
# test_that("sub_nonanswers rescales when requested", {
#     xt <- read_xtabs(demo_xt(2018), year = 2018, process = TRUE)
#     xt <- dplyr::filter(xt, code == "Q1", group == "Connecticut")
#     xt$value <- xt$value * 2
#     xt_sub1 <- suppressWarnings(sub_nonanswers(xt, rescale = FALSE))
#     xt_sub2 <- suppressWarnings(sub_nonanswers(xt, rescale = TRUE))
#     expect_false(sum(xt_sub1$value) == 1.0)
#     expect_true(sum(xt_sub2$value) == 1.0)
# })
#
# test_that("sub_nonanswers returns correct dimensions", {
#     xt <- read_xtabs(demo_xt(2018), year = 2018, process = TRUE)
#     xt <- dplyr::filter(xt, code == "Q1", group == "Connecticut")
#     xt_sub <- sub_nonanswers(xt)
#     expect_equal(nrow(xt), 4)
#     expect_equal(nrow(xt_sub), 2)
# })
