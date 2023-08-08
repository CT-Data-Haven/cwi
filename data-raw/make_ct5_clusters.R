ct5_clusters <- readr::read_csv("./data-raw/files/5CT_groups_2010.csv") |>
  dplyr::filter(!is.na(Cluster)) |>
  dplyr::select(Town, Cluster) |>
  stats::setNames(tolower(names(.))) |>
  dplyr::mutate(cluster = as.factor(cluster)) |>
  dplyr::mutate(cluster = forcats::fct_relevel(cluster, "Urban core", "Urban periphery", "Suburban", "Rural"))

usethis::use_data(ct5_clusters, overwrite = TRUE)
