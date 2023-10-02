import pandas as pd 

datasets = pd.read_csv('data-raw/datasets.txt', 
                       sep = ';',
                       header = None, 
                       names = ['script', 'data_in', 'data_out'],
                       index_col = 'script',
                       keep_default_na = False)
# replace NaN with None
# datasets['data_in'] = datasets['data_in'].apply(lambda x: None if x == '' else x)
# datasets['data_in'] = datasets['data_in'].str.split(' ')
datasets['data_out'] = datasets['data_out'].str.split(' ')
scripts = datasets.index.tolist()
data_in = datasets['data_in'].to_dict()
data_out = datasets['data_out'].to_dict()

rule data:
  input:
    data_in[script]
  output:
    data_out[script]
  script:
    expand('data-raw/make_{script}.R', script = scripts)

rule internal_data:
  input:
    'data-raw/make_laus_codes.R'
  output:
    'R/sysdata.rda'
  script:
    'data-raw/make_internal_data.R'

rule test_data:
  output:
    'inst/test_data/age_df.rds'
  script:
    'data-raw/make_testdata.R'