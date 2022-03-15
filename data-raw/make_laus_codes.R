# area types to keep: state A, county F, cities 25k+ G, cities <25k H
# laus_codes <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.area") %>%
#   dplyr::filter(area_text == "Connecticut" | stringr::str_detect(area_text, "( CT|CT )")) %>%
#   dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) %>%
#   dplyr::mutate(area = stringr::str_extract(area_text, "^([A-Z][a-z]+\\s?)+") %>% stringr::str_trim()) %>%
#   dplyr::select(type = area_type_code, area, code = area_code)


laus_measures <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.measure")

usethis::use_data(laus_measures, overwrite = TRUE)

laus_codes <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.area") %>%
  dplyr::mutate(state_code = substr(area_code, 3, 4)) %>%
  dplyr::left_join(dplyr::distinct(tidycensus::fips_codes, state_code, state), by = "state_code") %>%
  dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) %>%
  # dplyr::select(area_type_code, area_code, area_text, state_code) %>%
  dplyr::mutate(area = trimws(stringr::str_extract(area_text, "(([A-Z][a-z\\-\\.]+\\s?)|of\\s?)+"))) %>%
  dplyr::select(type = area_type_code, state_code, area, area_code)

usethis::use_data(laus_codes, overwrite = TRUE)
