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


#' New Haven neighborhoods by block group
#'
#' A dataset of New Haven neighborhoods delineated by Census tract and block group. Some block groups cross between more than one neighborhood; use `weight` column for aggregating values such as populations.
#'
#' @format A data frame with 110 rows and 5 variables:
#' \describe{
#'   \item{neighborhood}{Neighborhood name}
#'   \item{tract}{6-digit FIPS code of the tract}
#'   \item{block_group}{Single digit number of the block group}
#'   \item{weight}{Share of block group population in that neighborhood}
#'   \item{geoid}{12-digit FIPS code of the block group}
#' }
"nhv_bgrps"


#' New Haven neighborhoods by tract
#'
#' A dataset of New Haven neighborhoods delineated by Census tract. Some tracts cross between more than one neighborhood; use `weight` column for aggregating values such as populations.
#'
#' @format A data frame with 34 rows and 4 variables:
#' \describe{
#'   \item{neighborhood}{Neighborhood name}
#'   \item{tract}{6-digit FIPS code of the tract}
#'   \item{weight}{Share of block group population in that neighborhood}
#'   \item{geoid}{Full 11-digit FIPS code of the tract}
#' }
"nhv_tracts"


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
