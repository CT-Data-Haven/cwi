# WRITE: town_sf new_haven_sf stamford_sf bridgeport_sf hartford_sf tract_sf tract_sf19

# make sf objects of towns, neighborhoods
sf::sf_use_s2(FALSE)
town_sf <- tigris::county_subdivisions(state = "09", cb = TRUE, class = "sf", year = 2020) |>
    dplyr::select(name = NAME, GEOID, geometry) |>
    dplyr::arrange(GEOID)

tract_sf <- tigris::tracts(state = "09", cb = TRUE, class = "sf", year = 2020) |>
    dplyr::select(name = GEOID, geometry)
tract_sf19 <- tigris::tracts(state = "09", cb = TRUE, class = "sf", year = 2019) |>
    dplyr::select(name = GEOID, geometry)

# get neighborhoods from gh releases in scratchpad
# get_gh_asset <- function(repo, tag, files, download = TRUE) {
#   release <- gh::gh("/repos/CT-Data-Haven/{repo}/releases/tags/{tag}", repo = repo, tag = tag)[["assets"]]
#   filenames <- purrr::map_chr(release, \(x) x[["name"]])
#   urls <- purrr::map_chr(release, \(x) x[["browser_download_url"]])
#   urls <- urls[filenames %in% files]
#   if (download) {
#     purrr::walk(urls, \(x) download.file(x, basename(x)))
#   } else {
#     urls
#   }
# }
# system("gh release download geos --repo CT-Data-Haven/scratchpad -p 'all_city_nhoods.rds' -D data-raw/files --clobber")
nhoods <- readRDS(file.path("data-raw", "files", "all_city_nhoods.rds"))
names(nhoods) <- paste(names(nhoods), "sf", sep = "_")

list2env(nhoods, .GlobalEnv)

usethis::use_data(town_sf, overwrite = TRUE)
usethis::use_data(new_haven_sf, overwrite = TRUE)
usethis::use_data(stamford_sf, overwrite = TRUE)
usethis::use_data(bridgeport_sf, overwrite = TRUE)
usethis::use_data(hartford_sf, overwrite = TRUE)
usethis::use_data(tract_sf, overwrite = TRUE)
usethis::use_data(tract_sf19, overwrite = TRUE)

# force rerun
file.remove(file.path("data-raw", "files", "all_city_nhoods.rds"))
