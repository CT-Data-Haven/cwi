#' Variable labels from the 2022 ACS
#'
#' Dataset of ACS variable labels, loaded from `tidycensus::load_variables()` for 2022 and cleaned up slightly.
#'
#' This dataset is updated and renamed accordingly with each annual ACS release.
#'
#' @format A data frame with `r nrow(acs_vars22)` rows and 3 variables:
#' \describe{
#'   \item{name}{Variable code, where first 6 characters are the table number and last 3 digits are the variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
"acs_vars22"


#' Variable labels from the Decennial Census
#'
#' Dataset of Decennial Census variable labels, loaded from `tidycensus::load_variables()` and cleaned up slightly. 2010 and 2020 versions are saved separately and have different variable code formats.
#'
#' @format A data frame with 8959 rows (2010) or 9067 rows (2020) and 3 variables:
#' \describe{
#'   \item{name}{Variable code containing the table number and variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
"decennial_vars20"

#' @rdname decennial_vars20
"decennial_vars10"


#' Tables available from the Census Bureau API
#'
#' Dataset of tables available from the Census Bureau's API, filtered to include just mainland decennial summary files and ACS detailed tables. Useful for verifying which summary files are available for different years, as some codes have changed (3-year ACS was sunset, decennial summary files are now all demographic & housing characteristics tables). Also used internally for checking calls to `multi_geo_acs` and `multi_geo_decennial`.
#'
#' @format A data frame with `r nrow(cb_avail)` rows and 4 variables:
#' \describe{
#'   \item{vintage}{Vintage year of dataset}
#'   \item{program}{Program, either "acs" or "dec"}
#'   \item{survey}{Survey/summary file}
#'   \item{title}{Brief title, standardized}
#' }
#' @source [US Census Bureau API Discovery Tool](https://www.census.gov/data/developers/updates/new-discovery-tool.html)
"cb_avail"


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
#' @format A data frame with 392 rows and 3 variables:
#' \describe{
#'   \item{geoid}{GEOID/FIPS code}
#'   \item{name}{Name of MSA}
#'   \item{region}{String: whether MSA is inside or outside of New England}
#' }
#' @source US Census Bureau via `tidycensus`. Note that these are as of 2020.
"msa"


#' City neighborhoods by tract
#'
#' Datasets of neighborhoods for New Haven, Hartford/West Hartford, Stamford, and Bridgeport. Some tracts cross between more than one neighborhood; use `weight` column for aggregating values such as populations. Previously this included a block group version for New Haven, which I've removed; I'm also renaming `nhv_tracts` to `new_haven_tracts` for consistency.
#'
#' These were updated to 2020 tract definitions. There are still 2019 versions of weight tables with names ending in `"19"`; for the time being, those will stick around for use with pre-2020 data.
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

#' @rdname neighborhood_tracts
"new_haven_tracts19"

#' @rdname neighborhood_tracts
"bridgeport_tracts19"

#' @rdname neighborhood_tracts
"stamford_tracts19"

#' @rdname neighborhood_tracts
"hartford_tracts19"




#' Regions of Connecticut
#'
#' A dataset of Connecticut regions by town
#'
#' @format A named list of vectors, where names give the names of regions and vectors give the names of towns making up each region, including regional councils of governments.
#' @source DataHaven internal and CT OPM
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
#' A crosswalk of Connecticut's Census-designated places (CDP) to the towns (county subdivisions) intersecting with them.
#' With the 2010 boundaries, places were generally each within a single town, but the 2020 boundaries increased the number of places,
#' including ones that span multiple towns. This table now has weights to show how much of a place's population is in the
#' associated town. This version also includes all places, not just ones that differ from the corresponding town.
#' Note that places don't span the full state. All populations are from the 2020 decennial census, and overlaps are based on
#' fitting blocks within places.
#'
#' @format A data frame with 224 rows and 7 variables:
#' \describe{
#'   \item{town}{Town (county subdivision) name}
#'   \item{place}{CDP name}
#'   \item{place_geoid}{CDP FIPS code}
#'   \item{town_pop}{Population of the full town}
#'   \item{place_pop}{Population of the full CDP}
#'   \item{overlap_pop}{Population of the overlapping area, interpolated from block populations}
#'   \item{place_wt}{Share of CDP population included in the town-CDP overlapping area}
#' }
#' @source Spatial overlay of TIGER shapefiles and populations from the 2020 Decennial Census DHC table P1.
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

#' Census occupation codes
#'
#' A dataset of occupation groups and descriptions with both Census (OCC) codes and SOC codes. Occupations are grouped hierarchically. This is filtered from a Census crosswalk to include only top-level groups, except for the very broad management, business, science, and arts occupations group; for this one, the second level groups are treated as the major one. Often you'll just want the major groups, so you can filter by the `is_major_grp` column.
#'
#' @format A data frame with 32 rows and 5 columns:
#' \describe{
#'   \item{is_major_grp}{Logical: whether this is the highest level included}
#'   \item{occ_group}{Major occupation group name}
#'   \item{occ_code}{Census occupation code}
#'   \item{soc_code}{SOC code}
#'   \item{description}{Full text of occupation name}
#' }
#' @source US Census Bureau's industry & occupation downloads
"occ_codes"


#' LAUS area codes
#'
#' A dataset of area types and codes for states, counties, and towns across the US, as used for the Local Area Unemployment Statistics. These are needed to put together series names, like those used to make API calls in `qwi_industry`. This used to be filtered just for Connecticut.
#'
#' @format A data frame with 6625 rows and 4 variables:
#' \describe{
#'   \item{type}{Area type code}
#'   \item{state_code}{Two-digit state FIPS code}
#'   \item{area}{Area name}
#'   \item{area_code}{Area code}
#' }
#' @source This is a filtered and cleaned version of a file downloaded from [BLS](https://download.bls.gov/pub/time.series/la/la.area).
"laus_codes"


#' CT crosswalk
#'
#' A crosswalk between geographies in Connecticut, built off of TIGER shapefiles.
#'
#' @format A data frame with `r nrow(xwalk)` rows and `r ncol(xwalk)` variables:
#' \describe{
#'   \item{block}{Block FIPS code}
#'   \item{block_grp}{Block group FIPS code, based on county FIPS}
#'   \item{block_grp_cog}{Block group FIPS code, based on COG FIPS as of 2022 ACS}
#'   \item{tract}{Tract FIPS code, based on county FIPS}
#'   \item{tract_cog}{Tract FIPS code, based on COG FIPS as of 2022 ACS}
#'   \item{town}{Town name}
#'   \item{town_fips}{Town FIPS code, based on county FIPS}
#'   \item{town_fips_cog}{Town FIPS code, based on COG FIPS as of 2022 ACS}
#'   \item{county}{County name}
#'   \item{county_fips}{County FIPS code}
#'   \item{cog}{COG name}
#'   \item{cog_fips}{COG FIPS code}
#'   \item{msa}{Metro/micropolitan area name}
#'   \item{msa_fips}{Metro/micropolitan area FIPS code}
#'   \item{puma}{PUMA name}
#'   \item{puma_fips}{PUMA FIPS code, based on county FIPS}
#'   \item{puma_fips_cog}{PUMA FIPS code, based on COG FIPS as of 2022 ACS}
#' }
#' @source 2020 and 2022 (for COGs & towns) TIGER shapefiles
"xwalk"


#' Tract to town crosswalk
#'
#' A version of `cwi::xwalk` that only contains tracts and town names, and is deduplicated for tracts that span multiple towns.
#'
#' @format A data frame with 879 rows and 2 variables:
#' \describe{
#'   \item{tract}{Tract FIPS code}
#'   \item{town}{Town name}
#' }
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


#' ACS demo data - tenure
#'
#' This is a table of housing tenure data for Greater New Haven obtained with `multi_geo_acs`, to be used in testing and examples.
#'
#' @format A data frame with 45 rows and 5 variables:
#' \describe{
#'   \item{\code{level}}{Geographic level}
#'   \item{\code{name}}{Geography name}
#'   \item{\code{tenure}}{Tenure: total households, owner-occupied, or renter-occupied}
#'   \item{\code{estimate}}{Estimated count}
#'   \item{\code{share}}{Calculated share of households, or `NA` for total}
#' }
"gnh_tenure"


#' Proxy PUMAs
#'
#' This is a list of 2 data frames giving PUMAs that make reasonable approximations of designated regions, with weights to apply to both population- and household-based measures. The data frame labeled `county` uses county-based PUMAs and 2021 ACS values; the data frame `cog` uses the new COG-based PUMAs and 2022 ACS values. When working with PUMS data or other weighted surveys, multiply the weights in the proxy table with the weights from the survey to account for how much of the PUMA overlaps the region.
#'
#' @format A list of 2 data frames, `county` and `cog`, with 19 and 54 rows, respectively, and 6 variables:
#' \describe{
#' \item{\code{puma}}{7-digit PUMA FIPS code}
#' \item{\code{region}}{Region name}
#' \item{\code{pop}}{Total population in the overlapping area between the region and the PUMA}
#' \item{\code{hh}}{Total households in the overlapping area between the region and the PUMA}
#' \item{\code{pop_weight}}{Population weight: share of the PUMA's population that's included in the region, to be used for population-based survey analysis}
#' \item{\code{hh_weight}}{Household weight: share of the PUMA's households that are included in the region, to be used for household-based survey analysis}
#' }
#' @source 2021 & 2022 5-year ACS
"proxy_pumas"
