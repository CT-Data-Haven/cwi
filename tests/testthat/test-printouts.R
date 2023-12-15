test_that("geo_printout handles counties vs COGs", {
  expect_message(multi_test(year = 2021), "Counties: Fairfield County,")
  expect_message(multi_test(year = 2022), "COGs: Capitol COG, ")

  expect_message(multi_test(year = 2021), "all towns in all counties")
  expect_message(multi_test(year = 2022), "all towns in all COGs")

  expect_message(multi_test(year = 2021, counties = "Fairfield County"), "all towns in Fairfield County")
  expect_message(multi_test(year = 2022, counties = "Capitol COG"), "all towns in Capitol COG")
})
