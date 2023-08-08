regional <- readr::read_delim("data-raw/files/regional_school_dists.tsv", delim = ";") |>
  tidyr::separate_rows(towns, sep = ",") |>
  dplyr::mutate(district = paste("Regional School District", stringr::str_pad(district, width = 2, side = "left", pad = "0"))) |>
  dplyr::rename(town = towns)

# there are a few very small towns that don't seem to have any of their own schools. some towns are in regional districts but also operate their own school for elementary grades, e.g. Woodbridge has its own k-6 or so, then sends to Amity

has_district <- dplyr::distinct(cwi::tract2town, town) |>
  dplyr::inner_join(readr::read_csv("https://query.data.world/s/236wagrhv3gvxpb75hhtc77hoxbwmo") |>
                     janitor::clean_names() |>
                     dplyr::distinct(district_name) |>
                     dplyr::mutate(town = stringr::str_remove(district_name, " School District$")) , by = "town") |>
  dplyr::select(district = district_name, town)

# add note about crec--not included here
school_dists <- dplyr::bind_rows(regional, has_district) |>
  dplyr::arrange(district)

usethis::use_data(school_dists)
