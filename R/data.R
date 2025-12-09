#' Variable labels from the `r cwi:::endyears[["acs"]]` ACS
#'
#' Dataset of ACS variable labels, loaded from `tidycensus::load_variables()` for `r cwi:::endyears[["acs"]]` and cleaned up slightly.
#'
#' This dataset is updated with each annual ACS release, with an attribute `year` giving the ACS endyear of the dataset.
#'
#' @format A data frame with `r nrow(acs_vars)` rows and 3 variables:
#' \describe{
#'   \item{name}{Variable code, where first 6 characters are the table number and last 3 digits are the variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
#' @examples
#' # get the year
#' attr(acs_vars, "year")
#' @keywords ref-datasets
"acs_vars"


#' Variable labels from the Decennial Census
#'
#' Dataset of Decennial Census variable labels, loaded from `tidycensus::load_variables()` and cleaned up slightly. 2010 and `r cwi:::endyears[["decennial"]]` versions are saved separately and have different variable code formats. `decennial_vars` has an attribute `year` giving the year of the dataset.
#'
#' @format A data frame with `r nrow(decennial_vars10)` rows (2010) or `r nrow(decennial_vars)` rows (`r cwi:::endyears[["decennial"]]`) and 3 variables:
#' \describe{
#'   \item{name}{Variable code containing the table number and variable number}
#'   \item{label}{Readable label of each variable}
#'   \item{concept}{Table name}
#' }
#' @source US Census Bureau via `tidycensus`
#' @examples
#' # get the year
#' attr(decennial_vars, "year")
#'
#' @keywords ref-datasets
"decennial_vars"

#' @rdname decennial_vars
#' @format NULL
"decennial_vars10"



#' Common ACS table numbers
#'
#' Lists of ACS table numbers commonly used by DataHaven. `basic_table_nums` is used for making short profiles of towns, neighborhoods, and regions, while `ext_table_nums` is used for "extended" profiles, such as neighborhood profiles distributed as PDF on the DataHaven website.
#'
#' @keywords ref-datasets
#' @name table_nums
NULL

#' @format A named list, where names correspond to abbreviated subjects and string values correspond to table numbers.
#' @rdname table_nums
"basic_table_nums"

#' @format NULL
#' @rdname table_nums
"ext_table_nums"


#' Names and GEOIDs of regional MSAs
#'
#' A reference dataset of all the metropolitan statistical areas (MSAs) in the US, marked with whether they're in a New England state.
#'
#' @format A data frame with `r nrow(msa)` rows and 3 variables:
#' \describe{
#'   \item{geoid}{GEOID/FIPS code}
#'   \item{name}{Name of MSA}
#'   \item{region}{String: whether MSA is inside or outside of New England}
#' }
#' @source US Census Bureau via `tidycensus`. Note that these are as of 2020.
#' @keywords ref-datasets
"msa"


#' City neighborhoods by tract
#'
#' Datasets of neighborhoods for New Haven, Hartford/West Hartford, Stamford, and Bridgeport. Some tracts cross between more than one neighborhood; use `weight` column for aggregating values such as populations. Previously this included a block group version for New Haven, which I've removed; I'm also renaming `nhv_tracts` to `new_haven_tracts` for consistency.
#'
#' These were updated to 2020 tract definitions. There are still 2019 versions of weight tables with names ending in `"19"`; for the time being, those will stick around for use with pre-2020 data.
#'
#' Note also that there was an error in the tables for Stamford and Hartford/West Hartford where a few neighborhoods were given extra tracts from outside the town boundaries. This particularly would affect counts, such as population totals by neighborhood, and was based on poor alignment in doing spatial overlays. Fixed 5/22/2024.
#'
#' @format A data frame; the number of rows depends on the city.
#' \describe{
#'   \item{town}{For `hartford_tracts`, the name of the town, because both Hartford and West Hartford neighborhoods are included; otherwise, no `town` variable is needed}
#'   \item{name}{Neighborhood name}
#'   \item{geoid}{11-digit FIPS code of the tract}
#'   \item{tract}{6-digit FIPS code of the tract; same as geoid but missing state & county components.}
#'   \item{weight}{Share of tract's households in that neighborhood}
#' }
#' @name neighborhood_tracts
#' @keywords ref-datasets
NULL

#' @format NULL
#' @rdname neighborhood_tracts
"new_haven_tracts"

#' @format NULL
#' @rdname neighborhood_tracts
"bridgeport_tracts"

#' @format NULL
#' @rdname neighborhood_tracts
"stamford_tracts"

#' @format NULL
#' @rdname neighborhood_tracts
"hartford_tracts"

#' @format NULL
#' @rdname neighborhood_tracts
"new_haven_tracts19"

#' @format NULL
#' @rdname neighborhood_tracts
"bridgeport_tracts19"

#' @format NULL
#' @rdname neighborhood_tracts
"stamford_tracts19"

#' @format NULL
#' @rdname neighborhood_tracts
"hartford_tracts19"




#' Regions of Connecticut
#'
#' A dataset of Connecticut regions by town
#'
#' @format A named list of vectors, where names give the names of regions and vectors give the names of towns making up each region, including regional councils of governments.
#' @source DataHaven internal and CT OPM
#' @keywords ref-datasets
"regions"


#' Zip to town lookup
#'
#' A crosswalk of Connecticut's ZCTA5s and towns with shares of populations and households in overlapping areas. Each row corresponds to a combination of zip and town; therefore, some zips have more than one observation, as do towns.
#'
#' @format A data frame with `r nrow(zip2town)` rows and `r ncol(zip2town)` variables:
#' \describe{
#'   \item{town}{Town name}
#'   \item{zip}{5-digit zip code (ZCTA5)}
#'   \item{inter_pop}{Population in this intersection of zips and towns}
#'   \item{inter_hh}{Number of households in this intersection of zips and towns}
#'   \item{pct_of_town_pop}{Percentage of the town's population that is also in this zip}
#'   \item{pct_of_town_hh}{Percentage of the town's households that are also in this zip}
#'   \item{pct_of_zip_pop}{Percentage of the zip's population that is also in this town}
#'   \item{pct_of_zip_hh}{Percentage of the zip's households that are also in this town}
#' }
#' @source Cleaned-up version of the Census [2022 ZCTA to county subdivision relationship file](https://www2.census.gov/geo/docs/maps-data/data/rel2022/acs22_cousub22_zcta520_st09.txt), updated for Connecticut's 2022 revisions from counties to COGs.
#' @keywords ref-datasets
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
#' @format A data frame with `r nrow(village2town)` rows and 7 variables:
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
#' @keywords ref-datasets
"village2town"


#' School districts by town
#'
#' A crosswalk of Connecticut towns and school districts, including regional districts. Some very small towns don't operate their own schools and are not included here, whereas other towns are both part of a regional district and operate some of their own schools, most commonly their own elementary.
#'
#' Note that for aggregating by region, the Hartford-area regional district CREC is not included here, because it spans so many other towns that also run their own schools.CREC is of significant enough size that it should generally be included in Greater Hartford aggregations or as its own district for comparisons alongside e.g. Hartford and West Hartford.
#'
#' @format A data frame with `r nrow(school_dists)` rows and 2 variables:
#' \describe{
#'   \item{district}{School district name}
#'   \item{town}{Name of town included in district}
#' }
#' @source Distinct town-level district names come from the state's [data.world](https://data.world/state-of-connecticut/9k2y-kqxn). Regional districts and their towns come from EdSight.
#' @keywords ref-datasets
"school_dists"


#' NAICS industry codes
#'
#' A dataset of industry names with their NAICS codes. These are only the main sectors, not detailed industry codes.
#'
#' @format A data frame with `r nrow(naics_codes)` rows and 3 variables:
#' \describe{
#'   \item{industry}{NAICS code}
#'   \item{label}{Industry name}
#'   \item{ind_level}{Sector level: either "A" for all industries, or "2" for sectors}
#' }
#' @source This is just a filtered version of file downloaded from [LEHD](https://lehd.ces.census.gov/data/)
#' @keywords ref-datasets
"naics_codes"

#' Census occupation codes
#'
#' A dataset of occupation groups and descriptions with both Census (OCC) codes and SOC codes. Occupations are grouped hierarchically. This is filtered from a Census crosswalk to include only top-level groups, except for the very broad management, business, science, and arts occupations group; for this one, the second level groups are treated as the major one. Often you'll just want the major groups, so you can filter by the `is_major_grp` column.
#'
#' @format A data frame with `r nrow(occ_codes)` rows and 5 columns:
#' \describe{
#'   \item{is_major_grp}{Logical: whether this is the highest level included}
#'   \item{occ_group}{Major occupation group name}
#'   \item{occ_code}{Census occupation code}
#'   \item{soc_code}{SOC code}
#'   \item{description}{Full text of occupation name}
#' }
#' @source US Census Bureau's industry & occupation downloads
#' @keywords ref-datasets
"occ_codes"


#' CT crosswalk
#'
#' A crosswalk between geographies in Connecticut, built off of TIGER shapefiles. `tract2town` is a subset with just tracts and towns. Tracts that span multiple towns are deduplicated and listed with the town with the largest areal overlap.
#'
#' @format ## For `xwalk`:
#'  A data frame with `r nrow(xwalk)` rows and `r ncol(xwalk)` variables:
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
#' @keywords ref-datasets
"xwalk"


#' Tract to town crosswalk
#'
#' A version of `cwi::xwalk` that only contains tracts and town names, and is deduplicated for tracts that span multiple towns.
#'
#' @format ## For `tract2town`:
#' A data frame with `r nrow(tract2town)` rows and 3 variables:
#' \describe{
#'   \item{tract}{Tract FIPS code}
#'   \item{tract_cog}{Tract FIPS code, based on COG FIPS as of 2022 ACS}
#'   \item{town}{Town name}
#' }
#' @rdname xwalk
#' @keywords ref-datasets
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
#' @keywords ref-datasets
"ct5_clusters"





#' ACS demo data - tenure
#'
#' This is a table of housing tenure data for Greater New Haven obtained with `multi_geo_acs`, to be used in testing and examples.
#'
#' @format A data frame with `r nrow(gnh_tenure)` rows and 5 variables:
#' \describe{
#'   \item{level}{Geographic level}
#'   \item{name}{Geography name}
#'   \item{tenure}{Tenure: total households, owner-occupied, or renter-occupied}
#'   \item{estimate}{Estimated count}
#'   \item{share}{Calculated share of households, or `NA` for total}
#' }
#' @keywords example-datasets
"gnh_tenure"

#' ACS demo data - educational attainment
#'
#' This is a table of educational attainment data for adults ages 25 and up in a few New Haven-area towns obtained with `tidycensus::get_acs`, to be used in testing and examples.
#'
#' @format A data frame with `r nrow(education)` rows and `r ncol(education)` variables:
#' \describe{
#'   \item{name}{Town name}
#'   \item{edu_level}{Educational attainment}
#'   \item{estimate}{Estimated count}
#'   \item{moe}{Margin of error}
#' }
#' @keywords example-datasets
"education"


#' Proxy PUMAs
#'
#' This is a list of 2 data frames giving PUMAs that make reasonable approximations of designated regions, with weights to apply to both population- and household-based measures. The data frame labeled `county` uses county-based PUMAs and 2021 ACS values; the data frame `cog` uses the new COG-based PUMAs and 2022 ACS values. When working with PUMS data or other weighted surveys, multiply the weights in the proxy table with the weights from the survey to account for how much of the PUMA overlaps the region.
#'
#' The county-based table includes just non-county regions (e.g. Greater New Haven), but the COG-based table also includes "legacy" counties (e.g. New Haven County), since we assume that even if data isn't released for counties, some organizations might still want estimates based on those geographies.
#' See maps of proxies and their weights here: [https://ct-data-haven.github.io/cogs/proxy-geos.html](https://ct-data-haven.github.io/cogs/proxy-geos.html)
#'
#' **NOTE:** There are some PUMAs that are included in more than one region. When joining these tables with survey data, make sure you're allowing for duplicates of PUMAs.
#' @format A list of 2 data frames, `county` and `cog`, with `r nrow(proxy_pumas$county)` and `r nrow(proxy_pumas$cog)` rows, respectively, and 6 variables:
#' \describe{
#' \item{puma}{7-digit PUMA FIPS code}
#' \item{region}{Region name}
#' \item{pop}{Total population in the overlapping area between the region and the PUMA}
#' \item{hh}{Total households in the overlapping area between the region and the PUMA}
#' \item{pop_weight}{Population weight: share of the PUMA's population that's included in the region, to be used for population-based survey analysis}
#' \item{hh_weight}{Household weight: share of the PUMA's households that are included in the region, to be used for household-based survey analysis}
#' }
#' @examples
#' # proxies made from county-based PUMAs, use for pre-2022 ACS or other datasets
#' proxy_pumas$county
#'
#' # proxies made from COG-based PUMAs
#' proxy_pumas$cog
#' @source 2021 & 2022 5-year ACS
#' @keywords ref-datasets
"proxy_pumas"
