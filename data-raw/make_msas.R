# make list of regional MSAs via tidycensus
fips <- dplyr::data_frame(
  state = c("CT", "MA", "ME", "NH", "RI", "VT"),
  code = c("09", "23", "25", "33", "44", "50")
)

msa <- fips$code %>%
  purrr::map_dfr(~tidycensus::get_acs(geography = "metropolitan statistical area/micropolitan statistical area", table = "B01003", year = 2016, state = .) %>%
                   dplyr::select(GEOID, name = NAME) %>%
                   dplyr::filter(stringr::str_detect(name, "Metro Area"))) %>%
  dplyr::mutate(GEOID = stringr::str_sub(GEOID, 3, -1)) %>%
  dplyr::mutate(name = stringr::str_remove(name, " Metro Area.+$")) %>%
  unique()

usethis::use_data(msa)
