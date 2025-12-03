# Census occupation codes

A dataset of occupation groups and descriptions with both Census (OCC)
codes and SOC codes. Occupations are grouped hierarchically. This is
filtered from a Census crosswalk to include only top-level groups,
except for the very broad management, business, science, and arts
occupations group; for this one, the second level groups are treated as
the major one. Often you'll just want the major groups, so you can
filter by the `is_major_grp` column.

## Usage

``` r
occ_codes
```

## Format

A data frame with 32 rows and 5 columns:

- is_major_grp:

  Logical: whether this is the highest level included

- occ_group:

  Major occupation group name

- occ_code:

  Census occupation code

- soc_code:

  SOC code

- description:

  Full text of occupation name

## Source

US Census Bureau's industry & occupation downloads
