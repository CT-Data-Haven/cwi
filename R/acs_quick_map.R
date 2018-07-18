#' Quickly create a choropleth sketch
#'
#' This is a quick way to create a choropleth sketch of town-, neighborhood-, or tract-level data. Uses a corresponding `sf` object; as of June 2018, this `sf` object must be one that ships with this package, or otherwise be globally available and have a column `name`.
#'
#' @param data A data frame containing data by geography.
#' @param name Bare column name of location names to join; defaults `name`.
#' @param value Bare column name of numeric values to map; defaults `value`.
#' @param level String giving the desired geographic level; must be one of `"town"`, `"neighborhood"`, or `"tract"`. Defaults `"town"`.
#' @param city If geographic level is neighborhood, string of the corresponding city name to match to a spatial object.
#' @param n Number of breaks into which to bin values; defaults (approximately) 5.
#' @param palette String of a ColorBrewer palette; see [RColorBrewer::RColorBrewer()] for possible values. Defaults `"GnBu"`.
#' @param title String giving the title, if desired, for the plot.
#' @param ... Any other parameters to pass along to `geom_sf()`, such as `color` or `size`.
#' @return A ggplot
#' @examples
#' tidycensus::get_acs(geography = "county subdivision",
#' variables = c(median_age = "B01002_001"), state = "09", county = "09") %>%
#'   camiller::town_names(NAME) %>%
#'   dplyr::filter(NAME %in% regions$`Greater New Haven`) %>%
#'   acs_quick_map(name = NAME, value = estimate, title = "Median age by town, 2016", n = 6)
#' @export
acs_quick_map <- function(data, name = name, value = value, level = "town", city = NULL, n = 5, palette = "GnBu", title = NULL, ...) {
  # supply city if it's neighborhoods
  assertthat::assert_that(level %in% c("town", "neighborhood", "tract"), msg = "Valid geography levels are town, neighborhood, or tract.")

  if (level == "neighborhood" & is.null(city)) stop("If using neighborhoods, please supply a city name.")

  name_var <- rlang::enquo(name)
  value_var <- rlang::enquo(value)
  value_name <- rlang::quo_name(value_var)

  locations <- data %>% dplyr::pull(!!name_var) %>% unique()

  if (level == "neighborhood") {
    shape_name <- city %>%
      stringr::str_to_lower() %>%
      stringr::str_replace_all(" ", "_") %>%
      paste0("_sf")
    assertthat::assert_that(exists(shape_name), msg = sprintf("Please check the name of your city: does %s exist?", shape_name))
    shape <- get(shape_name)
    shape <- shape %>% dplyr::filter(name %in% locations)
  } else if (level == "tract") {
    shape <- tract_sf %>% dplyr::filter(name %in% locations)
    shape_name <- "tract_sf"
  } else {
    shape <- town_sf %>% dplyr::filter(name %in% locations)
    shape_name <- "town_sf"
  }

  assertthat::assert_that(nrow(shape) > 0, msg = "This sf object is empty. Are city and level set properly?")
  assertthat::assert_that(nrow(shape) > 2, msg = "This sf object is nearly empty. Are city and level set properly?")

  if (length(intersect(locations, shape$name)) < length(locations)) {
    extra_locs <- paste(locations[!locations %in% shape$name], collapse = ", ")
    warning(sprintf("Some locations in your data weren't found in the shape %s: %s", shape_name, extra_locs))
    locations <- locations[locations %in% shape$name]
  }

  if (length(locations) < n) {
    n <- ceiling(sqrt(length(locations)))
    warning(sprintf("n is too large; setting to %s instead", n))
  }

  # make shape$name, data$name_var characters if not already
  if (is.factor(shape$name)) shape$name <- as.character(shape$name)
  data_fct <- data %>%
    dplyr::ungroup()
  if (is.factor(data_fct$name)) data_fct$name <- as.character(data_fct$name)


  p <- shape %>%
    # dplyr::inner_join(data_fct, by = rlang::quo_name(name_var)) %>%
    dplyr::inner_join(data_fct, by = suppressWarnings(stats::setNames(rlang::quo_name(name_var), "name"))) %>%
    dplyr::mutate(brk = cut(!!value_var,
                          breaks = classInt::classIntervals(!!value_var, n = n, style = "jenks")$brk %>% unique(),
                          include.lowest = T)) %>%
    ggplot2::ggplot() +
    ggplot2::geom_sf(ggplot2::aes(fill = brk), ...) +
    ggplot2::scale_fill_brewer(palette = palette, drop = F) +
    ggplot2::theme_minimal() +
    ggplot2::coord_sf(ndiscr = F) +
    ggplot2::labs(fill = rlang::quo_name(value_var))
  if (!is.null(title)) p <- p + ggplot2::ggtitle(title)
  p
}

