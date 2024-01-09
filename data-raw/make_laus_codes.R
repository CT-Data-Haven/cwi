# area types to keep: state A, county F, cities 25k+ G, cities <25k H
# laus_codes <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.area") |>
#   dplyr::filter(area_text == "Connecticut" | stringr::str_detect(area_text, "( CT|CT )")) |>
#   dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) |>
#   dplyr::mutate(area = stringr::str_extract(area_text, "^([A-Z][a-z]+\\s?)+") |> stringr::str_trim()) |>
#   dplyr::select(type = area_type_code, area, code = area_code)

# bls updated the measures listed--for now, filter to the original 4

# no longer allows direct download--403 error
# got these headers from firefox devtools
headers <- list("User-Agent" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0",
                "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                "Accept-Language" = "en-US,en;q=0.5",
                "Accept-Encoding" = "gzip, deflate, br")
h1 <- curl::new_handle(); h2 <- curl::new_handle()
curl::handle_setheaders(h1, .list = headers)
curl::handle_setheaders(h2, .list = headers)

laus_measures <- curl::curl("https://download.bls.gov/pub/time.series/la/la.measure", open = "rb", handle = h1) |>
  readr::read_tsv() |>
  dplyr::filter(measure_code %in% c("03", "04", "05", "06"))

# make this internal
# usethis::use_data(laus_measures, overwrite = TRUE)

laus_codes <- curl::curl("https://download.bls.gov/pub/time.series/la/la.area", open = "rb", handle = h2) |>
  readr::read_tsv() |>
  dplyr::mutate(state_code = substr(area_code, 3, 4)) |>
  dplyr::left_join(dplyr::distinct(tidycensus::fips_codes, state_code, state), by = "state_code") |>
  dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) |>
  # dplyr::select(area_type_code, area_code, area_text, state_code) |>
  dplyr::mutate(area = trimws(stringr::str_extract(area_text, "(([A-Z][a-z\\-\\.]+\\s?)|of\\s?)+"))) |>
  dplyr::select(type = area_type_code, state_code, area, area_code)

usethis::use_data(laus_codes, overwrite = TRUE)
