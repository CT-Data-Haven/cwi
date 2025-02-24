#!/usr/bin/env bash
gh release download geos \
  --repo CT-Data-Haven/scratchpad \
  -p 'all_city_nhoods.rds' \
  -D data-raw/files \
  --clobber
