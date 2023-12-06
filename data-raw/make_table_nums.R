basic_table_nums <- list(
  total_pop = "B01003",
  sex_by_age = "B01001",
  race = "B03002",
  foreign_born = "B05001",
  tenure = "B25003",
  housing_cost = "B25106",
  vehicles = "B08201",
  education = "B06009",
  median_income = "B19013",
  poverty = "C17002",
  pov_age = "B17024"
)

ext_table_nums <- list(
  total_pop = "B01003",
  sex_age = "B01001",
  race = "B03002",
  family = "B11001",
  children = "B11003",
  vacancy = "B25004",
  tenure = "B25003",
  disconnect = "B14005",
  education = "B15002",
  immigration = "B05005",
  language = "B16004",
  labor = "B23025",
  commute = "B08301",
  parent_work = "B23008",
  occupation = "C24010",
  hh_income = "B19001",
  agg_income = "B19025",
  fam_income = "B19101",
  poverty = "C17002",
  pov_age = "B17024",
  fam_poverty = "B17010",
  vehicle = "B25044",
  crowding = "B25014",
  housing_val = "B25075",
  mortgage = "B25091",
  rent = "B25074"
)

usethis::use_data(basic_table_nums, overwrite = TRUE)
usethis::use_data(ext_table_nums, overwrite = TRUE)
