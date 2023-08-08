# make a set of data for testing separate_acs
# uses census api & doesn't need to run each time testing is done
age_df <- tidycensus::get_acs("county", table = "B01001", state = "09") |>
  label_acs() |>
  dplyr::select(geoid = GEOID, label) |>
  dplyr::slice(1:10)
saveRDS(age_df, system.file("test_data/age_df.rds", package = "cwi"))
