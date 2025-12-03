# Proxy PUMAs

This is a list of 2 data frames giving PUMAs that make reasonable
approximations of designated regions, with weights to apply to both
population- and household-based measures. The data frame labeled
`county` uses county-based PUMAs and 2021 ACS values; the data frame
`cog` uses the new COG-based PUMAs and 2022 ACS values. When working
with PUMS data or other weighted surveys, multiply the weights in the
proxy table with the weights from the survey to account for how much of
the PUMA overlaps the region.

## Usage

``` r
proxy_pumas
```

## Format

A list of 2 data frames, `county` and `cog`, with 61 and 82 rows,
respectively, and 6 variables:

- puma:

  7-digit PUMA FIPS code

- region:

  Region name

- pop:

  Total population in the overlapping area between the region and the
  PUMA

- hh:

  Total households in the overlapping area between the region and the
  PUMA

- pop_weight:

  Population weight: share of the PUMA's population that's included in
  the region, to be used for population-based survey analysis

- hh_weight:

  Household weight: share of the PUMA's households that are included in
  the region, to be used for household-based survey analysis

## Source

2021 & 2022 5-year ACS

## Details

The county-based table includes just non-county regions (e.g. Greater
New Haven), but the COG-based table also includes "legacy" counties
(e.g. New Haven County), since we assume that even if data isn't
released for counties, some organizations might still want estimates
based on those geographies. See maps of proxies and their weights here:
<https://ct-data-haven.github.io/cogs/proxy-geos.html>

**NOTE:** There are some PUMAs that are included in more than one
region. When joining these tables with survey data, make sure you're
allowing for duplicates of PUMAs.

## Examples

``` r
# proxies made from county-based PUMAs, use for pre-2022 ACS or other datasets
proxy_pumas$county
#> # A tibble: 61 × 6
#>    puma    region                   pop    hh pop_weight hh_weight
#>    <chr>   <chr>                  <dbl> <dbl>      <dbl>     <dbl>
#>  1 0900300 Capitol Region COG    154355 59417      0.987     0.986
#>  2 0900301 Capitol Region COG    110423 44599      1         1    
#>  3 0900302 Capitol Region COG    121562 46879      1         1    
#>  4 0900303 Capitol Region COG    165411 66333      1         1    
#>  5 0900304 Capitol Region COG     43474 17149      0.382     0.381
#>  6 0900305 Capitol Region COG    111643 44350      1         1    
#>  7 0900306 Capitol Region COG    119553 49100      1         1    
#>  8 0901300 Capitol Region COG    149188 56576      0.994     0.993
#>  9 0900101 Connecticut Metro COG  69339 23805      0.584     0.589
#> 10 0900104 Connecticut Metro COG 148529 52914      1         1    
#> # ℹ 51 more rows

# proxies made from COG-based PUMAs
proxy_pumas$cog
#> # A tibble: 82 × 6
#>    puma    region                pop    hh pop_weight hh_weight
#>    <chr>   <chr>               <dbl> <dbl>      <dbl>     <dbl>
#>  1 0920201 Capitol Region COG 121057 48277      1         1    
#>  2 0920202 Capitol Region COG 158475 62259      1         1    
#>  3 0920203 Capitol Region COG 116015 40349      1         1    
#>  4 0920204 Capitol Region COG 140741 57966      1         1    
#>  5 0920205 Capitol Region COG 113460 46805      1         1    
#>  6 0920206 Capitol Region COG 155435 61862      1         1    
#>  7 0920207 Capitol Region COG 160475 64338      1         1    
#>  8 0920301 Capitol Region COG  11507  4693      0.107     0.108
#>  9 0920703 Fairfield County    41206 15774      0.258     0.248
#> 10 0920801 Fairfield County   148470 55550      1         1    
#> # ℹ 72 more rows
```
