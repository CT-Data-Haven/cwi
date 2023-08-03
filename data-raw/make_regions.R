cogs <- sf::read_sf("https://data.ct.gov/resource/idnf-uwvz.geojson")
cogs <- dplyr::select(cogs, name = new_region)
cogs$name <- stringr::str_replace(cogs$name, "\\bCT\\b", "Connecticut")
cogs$name <- dplyr::recode(cogs$name,
                           "Greater Bridgeport" = "Connecticut Metro",
                           "South Central" = "South Central Regional",
                           "Southeastern" = "Southeastern Connecticut",
                           "Northeastern" = "Northeastern Connecticut",
                           "Western" = "Western Connecticut")
cogs$name <- paste(cogs$name, "COG")
cogs <- sf::st_transform(cogs, sf::st_crs(cwi::town_sf))
town2cog <- sf::st_join(dplyr::select(cwi::town_sf, town = name), cogs, largest = TRUE)
town2cog <- sf::st_drop_geometry(town2cog)
town2cog <- dplyr::select(town2cog, name, town)

town2reg <- readr::read_csv("./data-raw/files/town_region_lookup.csv")
town2reg <- dplyr::filter(town2reg, !is.na(region))
town2reg <- dplyr::select(town2reg, name = region, town)

regions <- rbind(town2reg, town2cog)
regions <- split(regions, regions$name)
regions <- purrr::map(regions, dplyr::pull, town)
regions <- purrr::map(regions, sort)


usethis::use_data(regions, overwrite = TRUE)

# Capitol Region COG
# Connecticut Metro COG
# Lower Connecticut River Valley COG
# Naugatuck Valley COG
# Northeastern COG
# Northwest Hills COG
# South Central Regional COG
# Southeastern Connecticut COG
# Western Connecticut COG
