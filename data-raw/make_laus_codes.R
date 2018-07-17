laus_codes <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.area") %>%
  dplyr::filter(area_text == "Connecticut" | stringr::str_detect(area_text, "( CT|CT )")) %>%
  dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) %>%
  dplyr::mutate(area = stringr::str_extract(area_text, "^([A-Z][a-z]+\\s?)+") %>% stringr::str_trim()) %>%
  dplyr::select(type = area_type_code, area, code = area_code)

usethis::use_data(laus_codes, overwrite = T)

laus_measures <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.measure")
