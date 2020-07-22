## Beiwe Surveys Preprocessing
## Colin Bosma

## PACKAGES
## -----------------------------------------------------------------------------

library(here)
library(tidyverse)
library(stringr)

## PRE-PROCESSING SURVEY ANSWERS
## -----------------------------------------------------------------------------


## Compiling survey data for one participant at a time:
## ----------------------------------

# Using a here() and piping approach.

# Have to do separately for each survey ID

here()
filefolder <- here("beiwe-data", "<Beiwe ID folder>", "survey_timings", "<survey ID>")
files <- dir(filefolder, pattern = "*.csv", full.names = TRUE); files
df <- files %>%
  map(read_csv) %>%
  reduce(rbind)

# Repeat code above for each survey ID, then combine
df <- reduce(c(df1, df2), rbind)

# Order by time
df <- df %>%
  group_by(`survey id`) %>%
  arrange(`UTC time`)
View(df)


## But can we make it into a function that does not depend on piping
get_survey <- function(surveyID_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}

# Let's test that function
df <- get_survey(here("survey_timings", "<survey ID>"))
View(df)


## Function for preprocessing all gyro data for all participants in a data folder:
## -----------------------------------------------------------------------------

# Notes:
  # The last two lines rearrange the data to be sequential via `UTC time` by participant and survey ID.
    # This is especially helpful if you have numerous surveys that were deployed for your study.

get_surveys_all <- function(parent_dir, id_position, match_string = "survey_timings/.*csv"){

  #recursively search ALL directories for files,
  #only return relative path of files that match "gps/<stuff>csv"
  all_files <- list.files(parent_dir, recursive = T, full.names = TRUE)[grep(pattern = match_string, list.files(parent_dir, recursive = T))]

  #returns data frame of ALL files in the all_files vector.
  #does data time split
  #adds beiweID as new column extracted from the input file.
  all_files %>%
    map_df(~{
      read_delim(.x, delim = ",")  %>%
        mutate(beiweID = str_split(.x, pattern = "/", simplify = TRUE)[id_position]) # id_position = level of directory with BeiweID
    })  %>%
    group_by(beiweID, `survey id`) %>% # group by Beiwe ID and survey ID
    arrange(`UTC time`) # arranges data by time for each participant
}

# match_string defaults to "gps/.*csv"
surveys_df <- get_surveys_all(parent_dir = "<path_to_data>", id_position = 6)
head(surveys_df)
