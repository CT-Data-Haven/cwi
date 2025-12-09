# WRITE: school_dists
reg_path <- file.path("data-raw", "files", "regional_school_dists.xlsx")
download.file(
    "https://edsight.ct.gov/relatedreports/Designated%20HS%20and%20Reg%20Dist.xlsx",
    destfile = reg_path
)
regional <- readxl::read_excel(reg_path, sheet = 1) |>
    dplyr::select(district = 2, town = 1) |>
    dplyr::distinct(district, town) |>
    dplyr::mutate(num = readr::parse_number(district)) |>
    dplyr::mutate(district = sprintf("Regional School District %02d", num)) |>
    dplyr::select(-num)

# there are a few very small towns that don't seem to have any of their own schools. some towns are in regional districts but also operate their own school for elementary grades, e.g. Woodbridge has its own k-6 or so, then sends to Amity

has_district <- dplyr::distinct(cwi::tract2town, town) |>
    dplyr::inner_join(
        readr::read_csv(
            "https://query.data.world/s/236wagrhv3gvxpb75hhtc77hoxbwmo"
        ) |>
            cwi:::clean_names() |>
            dplyr::distinct(district_name) |>
            dplyr::mutate(
                town = stringr::str_remove(district_name, " School District$")
            ),
        by = "town"
    ) |>
    dplyr::select(district = district_name, town)

# add note about crec--not included here
school_dists <- dplyr::bind_rows(regional, has_district) |>
    dplyr::arrange(district)

usethis::use_data(school_dists, overwrite = TRUE)
