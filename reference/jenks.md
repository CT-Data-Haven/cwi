# Quickly cut a vector with the Jenks/Fisher algorithms

Given a numeric vector, this returns a factor of those values cut into
`n` number of breaks using the Jenks/Fisher algorithms. The algorithm(s)
sets breaks in a way that highlights very high or very low values well.
It's good to use for choropleths that need to convey imbalances or
inequities.

## Usage

``` r
jenks(x, n = 5, true_jenks = FALSE, labels = NULL, ...)
```

## Arguments

- x:

  A numeric vector to cut

- n:

  Number of bins, Default: 5

- true_jenks:

  Logical: should a "true" Jenks algorithm be used? If false, uses the
  faster Fisher-Jenks algorithm. See
  [`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html)
  docs for discussion. Default: FALSE

- labels:

  A string vector to be used as bin labels, Default: NULL

- ...:

  Arguments passed on to [`base::cut`](https://rdrr.io/r/base/cut.html)

  :   

## Value

A factor of the same length as x

## See also

[`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html)

## Examples

``` r
set.seed(123)
values <- rexp(30, 0.8)
jenks(values, n = 4)
#>  [1] (0.535,1.36]   (0.535,1.36]   (1.36,2.71]    [0.0364,0.535] [0.0364,0.535]
#>  [6] [0.0364,0.535] [0.0364,0.535] [0.0364,0.535] (2.71,5.05]    [0.0364,0.535]
#> [11] (0.535,1.36]   (0.535,1.36]   [0.0364,0.535] [0.0364,0.535] [0.0364,0.535]
#> [16] (0.535,1.36]   (1.36,2.71]    (0.535,1.36]   (0.535,1.36]   (2.71,5.05]   
#> [21] (0.535,1.36]   (0.535,1.36]   (1.36,2.71]    (1.36,2.71]    (1.36,2.71]   
#> [26] (1.36,2.71]    (1.36,2.71]    (1.36,2.71]    [0.0364,0.535] (0.535,1.36]  
#> Levels: [0.0364,0.535] (0.535,1.36] (1.36,2.71] (2.71,5.05]
```
