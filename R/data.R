#' Variable labels from the ACS
#'
#' Dataset of ACS variable labels, loaded from `tidycensus::load_variables()` and cleaned up slightly.
#'
#' @format A data frame with 22815 rows and 3 variables:
#' \describe{
#'   \item{name}{Variable code, where first 6 characters are the table number and last 3 digits are the variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
"acs_vars"


#' Basic ACS table numbers
#'
#' List of ACS table numbers commonly used by DataHaven for making short profiles of towns, neighborhoods, and regions.
#'
#' @format A named list of length 11, where names correspond to abbreviated subjects and string values correspond to table numbers.
#' @seealso  [ext_table_nums]
"basic_table_nums"


#' Extended ACS table numbers
#'
#' List of ACS tables less commonly used by DataHaven. These are used for "extended" profiles, such as neighborhood profiles distributed as PDF on the DataHaven website.
#'
#' @format A named list of length 26, where names correspond to abbreviated subjects and string values correspond to table numbers.
#' @seealso [basic_table_nums]
"ext_table_nums"


#' Names and GEOIDs of regional MSAs
#'
#' A reference dataset of all the metropolitan statistical areas (MSAs) in New England.
#'
#' @format A data frame with 15 rows and 2 variables:
#' \describe{
#'   \item{GEOID}{GEOID/FIPS code}
#'   \item{name}{Name of MSA}
#' }
#' @source US Census Bureau via `tidycensus`
"msa"


#' City neighborhoods by tract or block group
#'
#' Datasets of neighborhoods for New Haven (both Census tract and block group available), Hartford/West Hartford, Stamford, and Bridgeport. Some tracts cross between more than one neighborhood; use `weight` column for aggregating values such as populations.
#'
#' @format A data frame
#' \describe{
#'   \item{town}{For `hartford_tracts`, the name of the town, because both Hartford and West Hartford neighborhoods are included; otherwise, no `town` variable is needed}
#'   \item{name}{Neighborhood name}
#'   \item{geoid}{FIPS code of smallest geography. For all but `nhv_bgrps`, this is the 11-digit FIPS code of the Census tract; for `nhv_bgrps`, this is the 12-digit FIPS code of the block group.}
#'   \item{tract}{6-digit FIPS code of the tract}
#'   \item{block_group}{Single digit number of the block group, if applicable (`nhv_bgrps`)}
#'   \item{weight}{Share of tract/block group households in that neighborhood}
#' }
#' @rdname tracts
"nhv_tracts"

#' @rdname tracts
"nhv_bgrps"

#' @rdname tracts
"bridgeport_tracts"

#' @rdname tracts
"stamford_tracts"

#' @rdname tracts
"hartford_tracts"




#' Regions of Connecticut
#'
#' A dataset of Connecticut regions by town
#'
#' @format A named list of vectors, where names give the names of regions and vectors give the names of towns making up each region.
#' @source DataHaven internal
"regions"


#' Zip to town lookup
#'
#' A crosswalk of Connecticut's ZCTA5s, towns, and town GEOIDs with shares of households in overlapping areas. Each row corresponds to a combination of zip and town; therefore, some zips have more than one observation, as do towns.
#'
#' @format A data frame with 407 rows and 7 variables:
#' \describe{
#'   \item{zip}{5-digit zip code (ZCTA5)}
#'   \item{town_geoid}{10-digit town FIPS code}
#'   \item{town}{Town name}
#'   \item{poppt}{Population living in this combination of zip and town}
#'   \item{hupt}{Number of housing units in this combination of zip and town}
#'   \item{pct_zip_hh_in_town}{Percentage of the zip's total households that are also in this town}
#'   \item{pct_town_hh_in_zip}{Percentage of the town's total households that are also in this zip}
#' }
#' @source Cleaned-up version of the Census [2010 ZCTA to county subdivision relationship file](https://www.census.gov/geo/maps-data/data/zcta_rel_download.html)
"zip2town"


#' NAICS industry codes
#'
#' A dataset of industry names with their NAICS codes. These are only the main sectors, not detailed industry codes.
#'
#' @format A data frame with 21 rows and 3 variables:
#' \describe{
#'   \item{industry}{NAICS code}
#'   \item{label}{Industry name}
#'   \item{ind_level}{Sector level: either "A" for all industries, or "2" for sectors}
#' }
#' @source This is just a filtered version of file downloaded from [LEHD](https://lehd.ces.census.gov/data/)
"naics_codes"
