test_that("geo_printout handles counties vs COGs", {
  expect_message(multi_test(year = 2021), "Counties: Fairfield County,")
  expect_message(multi_test(year = 2022), "COGs: Capitol COG, ")

  expect_message(multi_test(year = 2021), "all towns in all counties")
  expect_message(multi_test(year = 2022), "all towns in all COGs")

  expect_message(multi_test(year = 2021, counties = "Fairfield County"), "all towns in Fairfield County")
  expect_message(multi_test(year = 2022, counties = "Capitol COG"), "all towns in Capitol COG")
})

test_that("geo_printout removes duplicates", {
  regs <- cwi::regions[c("Greater Hartford", "Greater New Haven", "Greater Hartford")]
  expect_no_message(multi_test(regions = regs), message = "(Greater Hartford).+(\\1)")
})
