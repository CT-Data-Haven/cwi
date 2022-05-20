# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME = `sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
PKGVERS = `sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`

R_CMD = R -q -e 
SRC = $(R_CMD) "devtools::load_all(); source('$<')"

.PHONY: all check docs vignettes install clean gen_data

all: check README.md

############################# UTILS
check: DESCRIPTION
	$(R_CMD) "devtools::check(cran = FALSE)"

docs:
	$(R_CMD) "devtools::document()"

vignettes: vignettes/*.Rmd
	$(R_CMD) "devtools::build_vignettes()"

install:
	$(R_CMD) "devtools::install()"

README.md: README.Rmd 
	$(R_CMD) "devtools::build_readme()"

clean:
	@rm -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck

############################# DATASETS
gen_data: data/*.rda 

data/gnh_tenure.rda: data-raw/make_acs_demo.R 
	$(SRC)

data/acs_vars20.rda data/decennial_vars10: data-raw/make_acs_vars.R 
	$(SRC)

data/ct5_clusters.rda: data-raw/make_ct5_clusters.R data-raw/files/5CT_groups_2010.csv
	$(SRC)

data/cws_demo.rda: data-raw/make_cws_demo.R inst/extdata/test_xtab2015.xlsx
	$(SRC)

data/*_sf.rda: data-raw/make_geo_sf.R 
	$(SRC)

data/laus_codes.rda: data-raw/make_laus_codes.R 
	$(SRC)

data/occ_codes.rda: data-raw/make_lehd.R 
	$(SRC)

data/msa.rda: data-raw/make_msas.R 
	$(SRC)

data/*_tracts.rda: data-raw/make_neighborhood_weights.R 
	$(SRC)

data/*_tracts19.rda: data-raw/make_neighborhood_weights19.R 
	$(SRC)

data/regions.rda: data-raw/make_regions.R data-raw/files/town_region_lookup.csv 
	$(SRC)

data/school_dists.rda: data-raw/make_school_dists.R data-raw/files/regional_school_dists.tsv
	$(SRC)

data/basic_table_nums.rda data/ext_table_nums.rda: data-raw/make_table_nums.R 
	$(SRC)

data/village2town.rda: data-raw/make_village_town_xwalk.R 
	$(SRC)

data/xwalk.rda data/tract2town.rda: data-raw/make_xwalk.R 
	$(SRC)

data/zip2town.rda: data-raw/make_zip2town.R data-raw/files/zip2town.csv
	$(SRC)

R/sysdata.rda: data-raw/make_internal_data.R 
	$(SRC)

inst/extdata/test_data/age_df.rds: data-raw/make_testdata.R
	$(SRC)	

data-raw/make_internal_data.R: data-raw/make_laus_codes.R data-raw/make_acs_vars.R
	Rscript $@


