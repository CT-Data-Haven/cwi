#' Neighborhood shapefiles of Connecticut cities
#'
#' Data frames of neighborhoods of Connecticut cities with `sf` geometries. Includes Bridgeport, Hartford/West Hartford, New Haven, and Stamford.
#'
#' @format Data frames (classes `data.frame` and `sf`). In each, `name` is the name of each neighborhood, and `geometry` is the shape of each neighborhood as either a `sfc_POLYGON` or `sfc_MULTIPOLYGON` object. `hartford_sf` contains an additional variable, `town`, which marks the neighborhoods as being in Hartford or West Hartford.

#' @rdname neighborhoods
"bridgeport_sf"

#' @rdname neighborhoods
"hartford_sf"

#' @rdname neighborhoods
"new_haven_sf"

#' @rdname neighborhoods
"stamford_sf"


#' Connecticut town shapefile
#'
#' Data frame of Connecticut towns with `sf` geometries.
#'
#' @format Data frame of class `sf`.
#' \describe{
#'   \item{name}{Town name}
#'   \item{GEOID}{Town GEOID}
#'   \item{geometry}{Town geometry as `sfc_MULTIPOLYGON`}
#' }
"town_sf"


#' Connecticut tract shapefile
#'
#' Data frame of Connecticut tracts with `sf` geometries.
#'
#' @format Data frame of class `sf`.
#' \describe{
#'   \item{name}{Tract FIPS code}
#'   \item{geometry}{Tract geometry as `sfc_MULTIPOLYGON`}
#' }
"tract_sf"
