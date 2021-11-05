#' Variable labels from the 2019 ACS
#'
#' Dataset of ACS variable labels, loaded from `tidycensus::load_variables()` for 2019 and cleaned up slightly.
#'
#' This dataset is updated and renamed accordingly with each annual ACS release.
#'
#' @format A data frame with 27039 rows and 3 variables:
#' \describe{
#'   \item{name}{Variable code, where first 6 characters are the table number and last 3 digits are the variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
"acs_vars19"


#' Variable labels from the 2010 Decennial Census
#'
#' Dataset set Decennial Census variable labels, loaded from `tidycensus::load_variables()` and cleaned up slightly.
#'
#' @format A data frame with 3346 rows and 3 variables:
#' \describe{
#'   \item{name}{Variable code, where first 1 to 3 letters and 3 to 4 digits are the table number, and remaining characters are the variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name, including readable table number}
#' }
#' @source US Census Bureau via `tidycensus`
"decennial_vars10"


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
#' A reference dataset of all the metropolitan statistical areas (MSAs) in the US, marked with whether they're in a New England state.
#'
#' @format A data frame with 389 rows and 3 variables:
#' \describe{
#'   \item{GEOID}{GEOID/FIPS code}
#'   \item{name}{Name of MSA}
#'   \item{region}{String: whether MSA is inside or outside of New England}
#' }
#' @source US Census Bureau via `tidycensus`. Note that these are 2015 MSA definitions.
"msa"


#' City neighborhoods by tract
#'
#' Datasets of neighborhoods for New Haven, Hartford/West Hartford, Stamford, and Bridgeport. Some tracts cross between more than one neighborhood; use `weight` column for aggregating values such as populations. Previously this included a block group version for New Haven, which I've removed; I'm also renaming `nhv_tracts` to `new_haven_tracts` for consistency.
#'
#' @format A data frame
#' \describe{
#'   \item{town}{For `hartford_tracts`, the name of the town, because both Hartford and West Hartford neighborhoods are included; otherwise, no `town` variable is needed}
#'   \item{name}{Neighborhood name}
#'   \item{geoid}{11-digit FIPS code of the tract}
#'   \item{tract}{6-digit FIPS code of the tract; same as geoid but missing state & county components.}
#'   \item{weight}{Share of tract's households in that neighborhood}
#' }
#' @name neighborhood_tracts
NULL

#' @rdname neighborhood_tracts
"new_haven_tracts"

#' @rdname neighborhood_tracts
"bridgeport_tracts"

#' @rdname neighborhood_tracts
"stamford_tracts"

#' @rdname neighborhood_tracts
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


#' Village to town lookup
#'
#' A crosswalk of Connecticut's Census-designated places (CDP) to the towns (county subdivisions) containing them.
#'
#' @format A data frame with 90 rows and 4 variables:
#' \describe{
#'   \item{cdp_geoid}{7-digits CDP FIPS code}
#'   \item{place}{CDP name}
#'   \item{town_geoid}{10-digit town FIPS code}
#'   \item{town}{Town name}
#' }
#' @source Spatial overlay of TIGER shapefiles, plus manual additions of non-CDP villages when we run into them in the wild.
"village2town"


#' School districts by town
#'
#' A crosswalk of Connecticut towns and school districts, including regional districts. Some very small towns don't operate their own schools and are not included here, whereas other towns are both part of a regional district and operate some of their own schools, most commonly their own elementary.
#'
#' Note that for aggregating by region, the Hartford-area regional district CREC is not included here, because it spans so many other towns that also run their own schools.CREC is of significant enough size that it should generally be included in Greater Hartford aggregations or as its own district for comparisons alongside e.g. Hartford and West Hartford.
#'
#' @format A data frame with 195 rows and 2 variables:
#' \describe{
#'   \item{district}{School district name}
#'   \item{town}{Name of town included in district}
#' }
#' @source Distinct town-level district names come from the state's [data.world](https://data.world/state-of-connecticut/9k2y-kqxn). Regional districts and their towns come from combing through school district websites.
"school_dists"


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


#' LAUS area codes
#'
#' A dataset of area types and codes for Connecticut, as used for the Local Area Unemployment Statistics. These are needed to put together series names, like those used to make API calls in `qwi_industry`.
#'
#' @format A data frame with 178 rows and 3 variables:
#' \describe{
#'   \item{type}{Area type code}
#'   \item{area}{Area name}
#'   \item{code}{Area code}
#' }
#' @source This is a filtered and cleaned version of a file downloaded from [BLS](https://download.bls.gov/pub/time.series/la/la.area).
"laus_codes"


#' CT crosswalk
#'
#' A shortened version of the CT crosswalk file from the LEHD/LODES files, to translate between geographies in Connecticut.
#'
#' @format A data frame with 67465 rows and 11 variables:
#' \describe{
#'   \item{block}{Block FIPS code}
#'   \item{block_grp}{Block group FIPS code}
#'   \item{tract}{Tract FIPS code}
#'   \item{town}{Town name}
#'   \item{town_fips}{Town FIPS code}
#'   \item{county}{County name}
#'   \item{county_fips}{County FIPS code}
#'   \item{msa}{Metro/micropolitan area name}
#'   \item{msa_fips}{Metro/micropolitan area FIPS code}
#'   \item{puma}{PUMA name}
#'   \item{puma_fips}{PUMA FIPS code}
#' }
#' @source This is a filtered, cleaned, and pared down version of a file downloaded from [LEHD](https://lehd.ces.census.gov/data/lodes/LODES7/ct/), plus some spatial joins of TIGER shapefiles.
"xwalk"


#' Tract to town crosswalk
#'
#' A version of `cwi::xwalk` that only contains tracts and town names, and is deduplicated for tracts that span multiple towns.
#'
#' @format A data frame with 830 rows and 2 variables:
#' \describe{
#'   \item{tract}{Tract FIPS code}
#'   \item{town}{Town name}
#' }
#' @source This is a filtered, cleaned, and pared down version of a file downloaded from [LEHD](https://lehd.ces.census.gov/data/lodes/LODES7/ct/).
"tract2town"


#' Five Connecticuts clusters
#'
#' Cluster assignments for towns into "5 Connecticuts"--urban core, urban periphery, suburban, rural, and wealthy--based on median family income, poverty rate, and population density.
#'
#' @format A data frame with 169 rows and 2 variables:
#' \describe{
#'   \item{town}{Town name}
#'   \item{cluster}{Cluster label}
#' }
#'
#' @source Levy, Don: Five Connecticuts 2010 Update. (2015). Produced for Siena College Research Institute and DataHaven based on original 1990 and 2000 designations from "Levy, Don, Orlando Rodriguez, and Wayne Villemez. 2004. The Changing Demographics of Connecticut - 1990 to 2000. Part 2: The Five Connecticuts. Storrs, Connecticut: University of Connecticut, The Connecticut State Data Center, Series, no. OP 2004-01."
"ct5_clusters"


#' CWS demo data
#'
#' This is a sample of 2015 DataHaven Community Wellbeing Survey data for Greater New Haven with weights attached. It's more or less what's created in the crosstabs vignette, saved here for use in examples.
#'
#' @format A data frame with 100 rows and 7 variables:
#' \describe{
#'   \item{code}{Question code}
#'   \item{question}{Question text}
#'   \item{category}{Category: gender, age, etc.}
#'   \item{group}{Group: male, female, ages 18–34, etc.}
#'   \item{response}{Survey response}
#'   \item{value}{Percentage value}
#'   \item{weight}{Survey weight}
#' }
"cws_demo"
