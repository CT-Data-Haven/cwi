# Fix names of COGs

As Connecticut rolls out its use of COGs in place of counties, the names
of COGs might differ depending on who you ask (the Census Bureau, CTOPM,
or the COGs themselves). The crosswalk in
[`cwi::xwalk`](https://CT-Data-Haven.github.io/cwi/reference/xwalk.md)
uses the names as they come from the Census; this function then renames
them to match the COGs' apparent preferences.

## Usage

``` r
fix_cogs(x)
```

## Arguments

- x:

  A vector of names, either as a character or a factor.

## Value

A vector of the same length and type as input

## See also

xwalk regions

## Examples

``` r
fix_cogs(names(regions[1:6]))
#> [1] "6 wealthiest Fairfield County" "Capitol Region COG"           
#> [3] "Eastern cities"                "Fairfield County"             
#> [5] "Connecticut Metro COG"         "Connecticut Metro COG"        
```
