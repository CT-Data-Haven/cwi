naics_codes <- readr::read_csv("https://lehd.ces.census.gov/data/schema/latest/label_industry.csv", col_types = "ccc") %>%
  dplyr::filter(industry == "00" | ind_level == "2")

usethis::use_data(naics_codes, overwrite = T)
