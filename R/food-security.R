library(tidyverse)
library(readxl)
library(cwi)
library(httr)
library(jsonlite)

fairfield_towns <- regions[["Fairfield County"]]
new_haven_towns <- regions[["New Haven County"]]

# CT DOL "Town Employment and Wages" files use two slightly different column
# layouts across vintages (older files lack Year4/Qtr/TownCode columns), so
# each file is read with skip = 1 and columns renamed positionally.
read_town_emp <- function(path, year, qtr) {
  raw <- read_excel(path, sheet = 1, skip = 1, col_names = FALSE)

  if (ncol(raw) == 10) {
    names(raw) <- c("year", "qtr", "town_code", "town", "naics2",
                     "naics_title", "avg_emp", "wages", "avg_wages", "estabs")
  } else {
    names(raw) <- c("town", "naics2", "naics_title", "estabs",
                     "avg_emp", "wages", "avg_wages")
    raw$year <- year
    raw$qtr <- qtr
  }

  raw %>%
    fill(town, .direction = "down") %>%
    mutate(avg_emp = as.numeric(avg_emp),
           wages = as.numeric(wages),
           avg_wages = as.numeric(avg_wages),
           year = as.integer(year),
           qtr = as.integer(qtr))
}

# CT DOL also publishes a wide quarterly layout (one row per town/industry,
# with Q1-Q4 columns for establishments, average employment, and quarter
# wages side by side) - this reads that format and keeps just Q4.
read_town_emp_wide_q4 <- function(path, year) {
  raw <- read_excel(path, sheet = 1, skip = 2, col_names = FALSE)
  names(raw) <- c("town", "naics2", "naics_title",
                   "estabs_q1", "estabs_q2", "estabs_q3", "estabs_q4",
                   "emp_q1", "emp_q2", "emp_q3", "emp_q4",
                   "wages_q1", "wages_q2", "wages_q3", "wages_q4")

  raw %>%
    fill(town, .direction = "down") %>%
    transmute(town, naics2, naics_title,
              year = year, qtr = 4L,
              avg_emp = as.numeric(emp_q4),
              wages = as.numeric(wages_q4),
              avg_wages = wages / avg_emp)
}

wages_recent <- read_town_emp("TownEmp_2025Qtr4.xlsx", 2025, 4)
wages_mid <- read_town_emp("TownEmp_2021Qtr4.xlsx", 2021, 4)
wages_past <- read_town_emp_wide_q4("TownEmp_2020Qtr1-4.xlsx", 2020)

# naics2 == "00" is "Total - All Industries"; avg_wages is the average wage
# per employee for the quarter. Reporting it as-is (per quarter) rather than
# dividing by an assumed week count, since the files don't tell us the exact
# number of weeks in each quarter.
all_town_wages <- bind_rows(wages_recent, wages_mid, wages_past) %>%
  filter(naics2 == "00")

fairfield_all <- all_town_wages %>%
  filter(town %in% fairfield_towns)

fairfield_wages <- fairfield_all %>%
  transmute(town, year, qtr, avg_qtr_wage = round(avg_wages, 2)) %>%
  arrange(town, year)

fairfield_wages_wide <- fairfield_wages %>%
  pivot_wider(id_cols = town, names_from = year, values_from = avg_qtr_wage,
              names_prefix = "wage_") %>%
  mutate(pct_change_5yr = round((wage_2025 - wage_2020) / wage_2020 * 100, 1)) %>%
  arrange(town)

# County-level average quarterly wage is employment-weighted (sum of wages /
# sum of employment), not a plain average of the town figures above, since
# towns range from Sherman (~1k jobs) to Stamford (~90k jobs).
county_qtr_wage <- function(towns) {
  all_town_wages %>%
    filter(town %in% towns) %>%
    group_by(year, qtr) %>%
    summarise(total_wages = sum(wages, na.rm = TRUE),
              total_emp = sum(avg_emp, na.rm = TRUE),
              .groups = "drop") %>%
    transmute(year, qtr, avg_qtr_wage = round(total_wages / total_emp, 2)) %>%
    arrange(year)
}

fairfield_county_wages <- county_qtr_wage(fairfield_towns)
new_haven_county_wages <- county_qtr_wage(new_haven_towns)

# Sanity check: put both counties side by side.
county_wage_comparison <- bind_rows(
  fairfield_county_wages %>% mutate(county = "Fairfield", .before = 1),
  new_haven_county_wages %>% mutate(county = "New Haven", .before = 1)
) %>%
  pivot_wider(id_cols = county, names_from = year, values_from = avg_qtr_wage,
              names_prefix = "wage_") %>%
  mutate(pct_change_5yr = round((wage_2025 - wage_2020) / wage_2020 * 100, 1))

fairfield_wages
fairfield_wages_wide
county_wage_comparison

# CPI-U series (not seasonally adjusted) pulled live from the BLS API, so
# this stays current as new months/years become available - change these
# settings to shift the comparison window. Years match the Q4 wage
# comparison above (2020 vs. 2025); each year's value is averaged over
# Q4's months (Oct-Dec) to line up with the quarterly wage figures rather
# than picking a single month as a stand-in.
cpi_series_ids <- c(
  "CPI-U (all items)"        = "CUUR0000SA0",
  "Food"                     = "CUUR0000SAF1",
  "Food at home (groceries)" = "CUUR0000SAF11"
)
cpi_start_year <- 2020
cpi_end_year <- 2025
cpi_qtr_months <- c("October", "November", "December")

fetch_bls_cpi <- function(series_ids, start_year, end_year, key = Sys.getenv("BLS_KEY")) {
  resp <- POST(
    "https://api.bls.gov/publicAPI/v2/timeseries/data",
    body = list(seriesid = unname(as.list(series_ids)),
                startyear = as.character(start_year),
                endyear = as.character(end_year),
                registrationkey = key),
    encode = "json"
  )
  stop_for_status(resp)
  parsed <- fromJSON(content(resp, as = "text", encoding = "utf-8"))

  parsed$Results$series %>%
    as_tibble() %>%
    unnest(data) %>%
    mutate(value = as.numeric(value)) %>%
    left_join(tibble(seriesID = series_ids, series = names(series_ids)), by = "seriesID")
}

cpi_food <- fetch_bls_cpi(cpi_series_ids, cpi_start_year, cpi_end_year) %>%
  filter(periodName %in% cpi_qtr_months, year %in% c(cpi_start_year, cpi_end_year)) %>%
  group_by(series, year) %>%
  summarise(value = mean(value, na.rm = TRUE), .groups = "drop") %>%
  mutate(period = if_else(year == cpi_start_year, "cpi_start", "cpi_end")) %>%
  select(series, period, value) %>%
  pivot_wider(names_from = period, values_from = value) %>%
  mutate(pct_change = round((cpi_end - cpi_start) / cpi_start * 100, 1))

cpi_food
