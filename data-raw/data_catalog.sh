#!/usr/bin/env bash

# data-raw scripts have a header line with the names of datasets they write
file=data-raw/datasets.txt
rm -f $file
echo "script;input;output" > "$file"

for r in data-raw/make_*.R; do
  rbase=$(basename "$r")
  rbase=$(echo "$rbase" | sed 's/\.R$//' | sed 's/make_//')

  # get line from script starting with # WRITE or READ flag 
  df_out=$(grep -oP '(?<=^# WRITE\: ).+$' $r | tr -d ",")
  df_in=$(grep -oP '(?<=^# READ\: ).+$' $r | tr -d ",")
  # if more than 0 characters, write to file
  if [ ${#df_in} -gt 0 ] || [ ${#df_out} -gt 0 ]; then
    echo "$rbase;$df_in;$df_out" >> $file
  fi
done