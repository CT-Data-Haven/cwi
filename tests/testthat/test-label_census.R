test_that("label_census functions return labels for all variables", {
  acs <- readRDS(test_path("test_data/test_acs.rds"))
  acs_lbl <- label_acs(acs)
  expect_false(any(is.na(acs_lbl$label)))

  dec <- readRDS(test_path("test_data/test_dec.rds"))
  dec_lbl <- label_decennial(dec)
  expect_false(any(is.na(dec_lbl$label)))
})

test_that("label_census functions handle other variable columns", {
  acs <- readRDS(test_path("test_data/test_acs.rds")) |>
    dplyr::rename(vrbl = variable)
  acs_lbl <- label_acs(acs, variable = vrbl)
  expect_false(any(is.na(acs_lbl$label)))

  dec <- readRDS(test_path("test_data/test_dec.rds")) |>
    dplyr::rename(vrbl = variable)
  dec_lbl <- label_decennial(dec, variable = vrbl)
  expect_false(any(is.na(dec_lbl$label)))
})

test_that("label_census functions warn if variables without labels", {
  acs <- readRDS(test_path("test_data/test_acs.rds"))
  dec <- readRDS(test_path("test_data/test_dec.rds"))
  acs_dummy <- dplyr::add_row(acs, variable = c("X123", "Y456"))

  expect_warning(
    label_acs(dec)
  )
  expect_warning(
    label_acs(acs_dummy)
  )
})
