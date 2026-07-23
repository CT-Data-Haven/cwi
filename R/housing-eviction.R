library(tidyverse)
library(cwi)
library(dcws)

data_dir <- "Housing Eviction"
fairfield_towns <- regions[["Fairfield County"]]

# Eviction Lab tract-level data for all of CT
# filings_2020 is a legacy column name but holds the actual filing count for whatever month that row is (not just 2020)
# filings_avg_prepandemic_baseline is a fixed 2017-2019 monthly average that repeats every year
# but the flat file leaves it blank for the most recent calendar year
ct_raw <- read_csv(file.path(data_dir, "connecticut_monthly_2020_2021.csv"),
                    show_col_types = FALSE) %>%
  rename(filings = filings_2020) %>%
  mutate(month_date = my(month),
         cal_month = month(month_date),
         is_fairfield = str_starts(GEOID, "09001"))

# 2026-06 is a partial pull (last_updated 6/13/2026), drop it so totals aren't dragged down by a half-reported month
last_complete_month <- as.Date("2026-05-01")
ct_raw <- filter(ct_raw, month_date <= last_complete_month)

baseline_lookup <- ct_raw %>%
  filter(!is.na(filings_avg_prepandemic_baseline)) %>%
  distinct(GEOID, cal_month, filings_avg_prepandemic_baseline) %>%
  group_by(GEOID, cal_month) %>%
  summarise(baseline = mean(filings_avg_prepandemic_baseline), .groups = "drop")

ct <- ct_raw %>%
  left_join(baseline_lookup, by = c("GEOID", "cal_month"))

# "sealed" is a single statewide row for filings that can't be assigned to a tract
# it's included in CT totals but can't be attributed to Fairfield County specifically
ct_monthly <- ct %>%
  group_by(month_date) %>%
  summarise(filings = sum(filings, na.rm = TRUE),
            baseline = sum(baseline, na.rm = TRUE), .groups = "drop")

fairfield_monthly <- ct %>%
  filter(is_fairfield) %>%
  group_by(month_date) %>%
  summarise(filings = sum(filings, na.rm = TRUE),
            baseline = sum(baseline, na.rm = TRUE), .groups = "drop")

# Annual filings vs. the 2017-2019 baseline, Fairfield County and statewide
annualize <- function(monthly) {
  monthly %>%
    mutate(year = year(month_date)) %>%
    group_by(year) %>%
    summarise(months = n(), filings = sum(filings), baseline = sum(baseline), .groups = "drop") %>%
    mutate(pct_vs_baseline = round((filings / baseline - 1) * 100, 1))
}

fairfield_annual <- annualize(fairfield_monthly)
ct_annual <- annualize(ct_monthly)

fairfield_annual
ct_annual

# Month-by-month: was Fairfield County above or below its pre-pandemic
# (2017-19) baseline, and by how much?
fairfield_monthly_vs_baseline <- fairfield_monthly %>%
  mutate(pct_vs_baseline = round((filings / baseline - 1) * 100, 1),
         status = if_else(filings >= baseline, "above", "below")) %>%
  select(month_date, filings, baseline, pct_vs_baseline, status)

fairfield_monthly_vs_baseline %>% print(n = Inf)

# Two different comparisons
# (1) since_moratorium: last_complete_month vs. the month the moratorium ended
#     (Aug 2021) - answers "how have filings changed since the moratorium?"
# (2) recent_month: last_complete_month vs. its own 2017-2019 pre-pandemic
#     baseline - answers "how do filings compare to before the pandemic?"

moratorium_end_month <- as.Date("2021-08-01")

since_moratorium <- bind_rows(
  Fairfield = filter(fairfield_monthly, month_date %in% c(moratorium_end_month, last_complete_month)),
  Connecticut = filter(ct_monthly, month_date %in% c(moratorium_end_month, last_complete_month)),
  .id = "geography"
) %>%
  select(geography, month_date, filings) %>%
  mutate(period = if_else(month_date == moratorium_end_month, "moratorium_end", "recent")) %>%
  select(-month_date) %>%
  pivot_wider(names_from = period, values_from = filings) %>%
  mutate(pct_change_since_moratorium = round((recent / moratorium_end - 1) * 100, 1))

since_moratorium

recent_month <- bind_rows(
  Fairfield = filter(fairfield_monthly, month_date == last_complete_month),
  Connecticut = filter(ct_monthly, month_date == last_complete_month),
  .id = "geography"
) %>%
  mutate(pct_vs_baseline = round((filings / baseline - 1) * 100, 1))

recent_month

# Renter households from the most recent (2024) 5-year ACS, summed across Fairfield County's 23 towns
# Fairfield County built town by town. multi_geo_acs() fetches a Connecticut
# statewide total in the same call (level "1_state"), so we keep the raw pull
# around instead of requesting it separately.
tenure_raw <- multi_geo_acs(table = "B25003", towns = fairfield_towns, year = 2024,
                             verbose = FALSE)

tenure <- tenure_raw %>%
  filter(level == "3_town") %>%
  mutate(var_label = case_when(
    variable == "B25003_001" ~ "total",
    variable == "B25003_002" ~ "owner",
    variable == "B25003_003" ~ "renter"
  )) %>%
  select(town = name, var_label, estimate) %>%
  pivot_wider(names_from = var_label, values_from = estimate)

fairfield_renter_hh <- sum(tenure$renter)
bridgeport_renter_hh <- tenure$renter[tenure$town == "Bridgeport"]

ct_renter_hh <- tenure_raw %>%
  filter(level == "1_state", variable == "B25003_003") %>%
  pull(estimate)

# Jan-May 2026 filings and rate per 10,000 renter households, Fairfield County
jan_may_2026 <- fairfield_monthly %>%
  filter(month_date >= as.Date("2026-01-01"), month_date <= last_complete_month) %>%
  summarise(filings = sum(filings)) %>%
  mutate(filings_per_10k_renter_hh = round(filings / fairfield_renter_hh * 10000, 1))

jan_may_2026

# Statewide vs. Fairfield County eviction filing rate, monthly average since
# Jan 2025. Renter households are held fixed at the 2024 5-year ACS estimate
# for both geographies (annual data, so it can't track month to month).
rate_start <- as.Date("2025-01-01")

statewide_vs_fairfield_rate <- bind_rows(
  Connecticut = filter(ct_monthly, month_date >= rate_start, month_date <= last_complete_month),
  Fairfield = filter(fairfield_monthly, month_date >= rate_start, month_date <= last_complete_month),
  .id = "geography"
) %>%
  mutate(renter_hh = if_else(geography == "Connecticut", ct_renter_hh, fairfield_renter_hh),
         rate_per_10k_renter_hh = filings / renter_hh * 10000) %>%
  group_by(geography) %>%
  summarise(months = n(),
            avg_monthly_filings = round(mean(filings), 0),
            avg_monthly_rate_per_10k = round(mean(rate_per_10k_renter_hh), 1),
            .groups = "drop") %>%
  mutate(fairfield_multiple_of_statewide = round(
    avg_monthly_rate_per_10k / avg_monthly_rate_per_10k[geography == "Connecticut"], 2))

statewide_vs_fairfield_rate

# Bridgeport vs. the rest of Fairfield County, 2025 eviciton filings.
# Uses the tract-to-town crosswalk as Eviction Lab's Bridgeport city file covers all 227 Fairfield County tracts)
bridgeport_2025_filings <- ct %>%
  filter(is_fairfield, year(month_date) == 2025) %>%
  left_join(select(tract2town, GEOID = tract, town), by = "GEOID") %>%
  filter(town == "Bridgeport") %>%
  summarise(filings = sum(filings, na.rm = TRUE)) %>%
  pull(filings)

fairfield_2025_filings <- fairfield_annual %>% filter(year == 2025) %>% pull(filings)
rest_of_county_2025_filings <- fairfield_2025_filings - bridgeport_2025_filings
rest_of_county_renter_hh <- fairfield_renter_hh - bridgeport_renter_hh

bridgeport_vs_rest <- tibble(
  bridgeport_rate_per_10k = round(bridgeport_2025_filings / bridgeport_renter_hh * 10000, 1),
  rest_of_county_rate_per_10k = round(rest_of_county_2025_filings / rest_of_county_renter_hh * 10000, 1),
  bridgeport_multiple_of_rest = round(bridgeport_rate_per_10k / rest_of_county_rate_per_10k, 2)
)

bridgeport_vs_rest

# Which Fairfield County towns have the most elevated eviction rates,
# Jan-May 2026 (same window as jan_may_2026 above)?
# Same tract-to-town crosswalk approach as bridgeport_2025_filings above,
# generalized to all 23 towns and compared against each town's own renter
# household base (2024 5-year ACS).
# GEOID 09001990000 is a non-populated tract (no town in the crosswalk,
# e.g. water/institutional) - excluded here the same way "sealed" is excluded
# from fairfield_monthly, so it doesn't show up as an NA town row.
fairfield_town_filings_jan_may_2026 <- ct %>%
  filter(is_fairfield, month_date >= as.Date("2026-01-01"), month_date <= last_complete_month,
         GEOID != "09001990000") %>%
  left_join(select(tract2town, GEOID = tract, town), by = "GEOID") %>%
  group_by(town) %>%
  summarise(filings = sum(filings, na.rm = TRUE), .groups = "drop")

# NOTE: towns with small renter-household bases (e.g. Monroe, Trumbull) can
# swing to a high rate_per_10k_renter_hh on relatively few filings over a
# 5-month window - check the filings column alongside the rate before reading
# too much into the smaller towns.
fairfield_town_rates_jan_may_2026 <- fairfield_town_filings_jan_may_2026 %>%
  left_join(select(tenure, town, renter), by = "town") %>%
  mutate(rate_per_10k_renter_hh = round(filings / renter * 10000, 1)) %>%
  arrange(desc(rate_per_10k_renter_hh))

fairfield_town_rates_jan_may_2026

# Chart: monthly eviction filings vs. pre-pandemic baseline, Fairfield County
# used to double check new data matched trends shown in 2023 CWI figure 4G

moratorium_end <- as.Date("2021-08-01")

fairfield_chart <- ggplot(fairfield_monthly, aes(x = month_date)) +
  geom_col(aes(y = filings, fill = "Monthly filings"), width = 27, show.legend = TRUE) +
  geom_line(aes(y = baseline, color = "2017-19 monthly average"),
            linewidth = 0.9, linetype = "22") +
  geom_vline(xintercept = moratorium_end, linetype = "dashed",
             color = "#898781", linewidth = 0.6) +
  annotate("text", x = moratorium_end, y = max(fairfield_monthly$filings) * 1.04,
           label = "Moratorium ends\n(Aug. 2021)", hjust = -0.05, vjust = 1,
           size = 3.2, color = "#52514e", lineheight = 0.9) +
  scale_fill_manual(name = NULL, values = c("Monthly filings" = "#2a78d6")) +
  scale_color_manual(name = NULL, values = c("2017-19 monthly average" = "#52514e")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Monthly eviction filings, Fairfield County",
       subtitle = "January 2020-May 2026",
       x = NULL, y = "Eviction filings",
       caption = "Source: Eviction Lab. 2017-19 average is a fixed pre-pandemic\nbaseline for each calendar month. June 2026 excluded (partial data pull).") +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "#e1e0d9", linewidth = 0.4),
    axis.line.x = element_line(color = "#c3c2b7", linewidth = 0.4),
    axis.ticks.x = element_line(color = "#c3c2b7", linewidth = 0.4),
    legend.position = "top",
    legend.justification = "left",
    plot.title = element_text(face = "bold", color = "#0b0b0b"),
    plot.subtitle = element_text(color = "#52514e"),
    plot.caption = element_text(color = "#898781", hjust = 0, size = 8),
    axis.text = element_text(color = "#52514e")
  )

fairfield_chart

ggsave(file.path(data_dir, "fairfield_monthly_filings_chart.png"), fairfield_chart,
       width = 9, height = 5.2, dpi = 200, bg = "#fcfcfb")

# DataHaven Community Wellbeing Survey: eviction-risk proportion

# Q14 ("How likely is it that your household will have to leave this home or
# apartment within the next two months") is only asked of respondents who say
# no to Q13 ("Is this household currently caught up on rent/mortgage
# payments"), and Q13 in turn is only asked of renters and mortgaged owners
# (Q11 own/rent, restricted further by QOWN for outright vs morgaged owners
cws_2025 <- fetch_cws(.year = 2025)

get_cws_q <- function(qcode) {
  cws_2025 %>%
    filter(name == "Connecticut", code == qcode) %>%
    unnest(data) %>%
    filter(category %in% c("Race/Ethnicity", "Gender")) %>%
    select(category, group, response, value)
}

q11 <- get_cws_q("Q11") %>%
  filter(response %in% c("I rent my home", "I own my home")) %>%
  pivot_wider(names_from = response, values_from = value) %>%
  rename(rent = `I rent my home`, own = `I own my home`)

qown <- get_cws_q("QOWN") %>%
  filter(response == "Owned with mortgage/loan") %>%
  select(category, group, pct_mortgage = value)

q13 <- get_cws_q("Q13") %>%
  filter(response == "No") %>%
  select(category, group, pct_not_caught_up = value)

q14 <- get_cws_q("Q14") %>%
  filter(response %in% c("Very likely", "Somewhat likely")) %>%
  group_by(category, group) %>%
  summarise(pct_likely_leave = sum(value), .groups = "drop")

# Q11 x QOWN x Q13 x Q14 
# Reconstructs the share of the full population who are behind on payments and likely to have to leave
cws_full_chain <- q11 %>%
  left_join(qown, by = c("category", "group")) %>%
  left_join(q13, by = c("category", "group")) %>%
  left_join(q14, by = c("category", "group")) %>%
  mutate(
    own_with_mortgage = own * pct_mortgage,
    base_asked_q13 = rent + own_with_mortgage,
    pct_not_caught_up_pop = base_asked_q13 * pct_not_caught_up,
    pct_population = round(pct_not_caught_up_pop * pct_likely_leave * 100, 2)
  ) %>%
  select(category, group, pct_population)

cws_full_chain