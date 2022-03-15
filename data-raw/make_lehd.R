naics_codes <- readr::read_csv("https://lehd.ces.census.gov/data/schema/latest/label_industry.csv", col_types = "ccc") %>%
  dplyr::filter(industry == "00" | ind_level == "2")

usethis::use_data(naics_codes, overwrite = TRUE)

# loading status: years available in api by state
qwi_avail <- rvest::read_html("https://ledextract.ces.census.gov/loading_status.html") %>%
  rvest::html_table() %>%
  `[[`(1) %>%
  janitor::clean_names() %>%
  dplyr::mutate(dplyr::across(start_quarter:end_quarter, ~as.numeric(stringr::str_extract(., "\\d{4}")))) %>%
  dplyr::inner_join(dplyr::distinct(tidycensus::fips_codes, state, state_code), by = "state") %>%
  dplyr::select(state_code, start_year = start_quarter, end_year = end_quarter)

usethis::use_data(qwi_avail, overwrite = TRUE)
