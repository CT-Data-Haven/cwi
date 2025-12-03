# Print unique values from a data frame column, then keep it moving

`show_uniq` gets the unique values of a column and their position within
that vector, prints them neatly to the console, then returns the
original data frame unchanged. It's just a convenience for showing the
values in a column without breaking your workflow or train of thought,
and is useful for identifying groups for `add_grps`.

## Usage

``` r
show_uniq(data, col)
```

## Arguments

- data:

  A data frame

- col:

  Bare column name of interest

## Value

Original unchanged `data`

## Examples

``` r
# show_uniq makes it easy to see that the values of `edu_level` that correspond
# to less than high school are in positions 2-16, and so on
education |>
    dplyr::group_by(name) |>
    show_uniq(edu_level) |>
    add_grps(
        list(
            ages25plus = 1,
            less_than_high_school = 2:16,
            high_school_plus = 17:25,
            bachelors_plus = 22:25
        ),
        group = edu_level, value = estimate
    )
#> 
#>   1: Total                                    
#>   2: No schooling completed                   
#>   3: Nursery school                           
#>   4: Kindergarten                             
#>   5: 1st grade                                
#>   6: 2nd grade                                
#>   7: 3rd grade                                
#>   8: 4th grade                                
#>   9: 5th grade                                
#>  10: 6th grade                                
#>  11: 7th grade                                
#>  12: 8th grade                                
#>  13: 9th grade                                
#>  14: 10th grade                               
#>  15: 11th grade                               
#>  16: 12th grade, no diploma                   
#>  17: Regular high school diploma              
#>  18: GED or alternative credential            
#>  19: Some college, less than 1 year           
#>  20: Some college, 1 or more years, no degree 
#>  21: Associate's degree                       
#>  22: Bachelor's degree                        
#>  23: Master's degree                          
#>  24: Professional school degree               
#>  25: Doctorate degree                        
#> 
#> # A tibble: 20 × 3
#> # Groups:   name [5]
#>    name       edu_level             estimate
#>    <chr>      <fct>                    <dbl>
#>  1 Bethany    ages25plus                3725
#>  2 Bethany    less_than_high_school      130
#>  3 Bethany    high_school_plus          3595
#>  4 Bethany    bachelors_plus            2193
#>  5 East Haven ages25plus               20768
#>  6 East Haven less_than_high_school     1724
#>  7 East Haven high_school_plus         19044
#>  8 East Haven bachelors_plus            5201
#>  9 Hamden     ages25plus               41017
#> 10 Hamden     less_than_high_school     2375
#> 11 Hamden     high_school_plus         38642
#> 12 Hamden     bachelors_plus           19132
#> 13 New Haven  ages25plus               84441
#> 14 New Haven  less_than_high_school    11853
#> 15 New Haven  high_school_plus         72588
#> 16 New Haven  bachelors_plus           31866
#> 17 West Haven ages25plus               35813
#> 18 West Haven less_than_high_school     4393
#> 19 West Haven high_school_plus         31420
#> 20 West Haven bachelors_plus           10399
```
