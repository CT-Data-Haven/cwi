# Check availability of different APIs with error catching

Check availability of different APIs with error catching

## Usage

``` r
safe_read_avail(url, type, query = NULL)
```

## Arguments

- url:

  URL for API call

- type:

  File type, currently json or html

- query:

  Optional query args as a list, added in order to pass a key to census
  api
