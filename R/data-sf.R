#' Neighborhood shapefiles of Connecticut cities
#'
#' Data frames of neighborhoods of Connecticut cities with `sf` geometries. Includes Bridgeport, Hartford/West Hartford, New Haven, and Stamford.
#'
#' @format Data frames (classes `data.frame` and `sf`). In each, `name` is the name of each neighborhood, and `geometry` is the shape of each neighborhood as either a `sfc_POLYGON` or `sfc_MULTIPOLYGON` object. `hartford_sf` contains an additional variable, `town`, which marks the neighborhoods as being in Hartford or West Hartford.
#' @source All neighborhood boundaries, with the exception of West Hartford, come directly from their respective cities' online data portals. West Hartford neighborhood boundaries are based directly on current tracts; the common names corresponding to tracts were scraped from a third-party real estate site.
#' @keywords shapefiles
#' @name neighborhood_shapes
NULL

#' @rdname neighborhood_shapes
"bridgeport_sf"

#' @rdname neighborhood_shapes
"hartford_sf"

#' @rdname neighborhood_shapes
"new_haven_sf"

#' @rdname neighborhood_shapes
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
#' @keywords shapefiles
"town_sf"


#' Connecticut tract shapefile
#'
#' Data frame of Connecticut tracts with `sf` geometries. `tract_sf19` is the 2019 version, should you need an older shapefile.
#'
#' @format Data frame of class `sf`.
#' \describe{
#'   \item{name}{Tract FIPS code}
#'   \item{geometry}{Tract geometry as `sfc_MULTIPOLYGON`}
#' }
#' @keywords shapefiles
"tract_sf"

#' @rdname tract_sf
"tract_sf19"
