## Beiwe Power State Pre-Processing 
## Colin M. Bosma

# Notes:
# 


## PACKAGES
## -----------------------------------------------------------------------------

library(tidyverse)
library(here)

## SETTING WORKSPACE

here::here()

## Power State Pre-processing 
## -----------------------------------------------------------------------------

## NOTES
# This function is intended to read in all of the .csv files for powerstate and 
# combine them into one dataframe
# Goal is to pull each spreadsheet and combine by row.

get_power_state = function(mypath, beiweID){
  filenames = list.files(path = mypath, full.names=TRUE)
  datalist  = lapply(filenames, function(x){read.csv(file=x,header=T)})
  tempDF  = do.call(rbind_list, datalist)
  beiweID = rep(beiweID, length = tempDF)
  newDF = cbind(beiweID, tempDF)
}

# test funciton
df <- powerstate_preprocess(mypath = "path-to-power_state-folder", beiweID = "beiweID")
# Example
df <- powerstate_preprocess(mypath = "/Users/colinbosma/Downloads/ever-data/8qpsyamw/power_state", beiweID = "8qpsyamw")  
View(df)
# Note: 
# The output changes the UTC data-time variable name to "UTC.time"

## Plyr approach

get_power_state <- function(mypath, beiweID){
  myfiles = list.files(path = mypath, pattern = "*.csv", full.names = TRUE)
  tempDF = plyr::ldply(myfiles, read_csv)
  beiweID = rep(beiweID, length.out = tempDF)
  newDF = cbind(beiweID, tempDF)
}

df <- powerstate_preproc(mypath = "/Users/colinbosma/Downloads/ever-data/8qpsyamw/power_state",
                  beiweID = "8qpsyamw")
View(df)
# note:
# UTC data-time varialbe is kept the same, with a space. 


## Function for preprocessing all power state data for all participants in a data folder

get_power_state_all <- function(parent_dir, id_position, match_string = "power_state/.*csv"){
  
  #recursively search ALL directories for files, 
  #only return relative path of files that match "power_state/<stuff>csv"
  all_files <- list.files(parent_dir, recursive = T, full.names = TRUE)[grep(pattern = match_string, list.files(parent_dir, recursive = T))]
  
  #returns data frame of ALL files in the all_files vector.
  #does data time split 
  #adds beiweID as new column extracted from the input file. 
  all_files %>% 
    map_df(~{
      read_delim(.x, delim = ",")  %>% 
        mutate(beiweID = str_split(.x, pattern = "/", simplify = TRUE)[id_position]) # id_position = level of directory with BeiweID
    })
}

# match_string defaults to "power_state/.*csv"
power_df <- get_power_state_all(parent_dir = "/Users/colinbosma/Dropbox/github/beiwe-preprocessing/data", id_position = 8)

head(power_df) 















