## Beiwe Accelerometer Preprocessing
## Colin Bosma


## PACKAGES
## -----------------------------------------------------------------------------

library(tidyverse)
library(here)

## Compiling data for one participant at a time:
## --------------------------------------------

# Using a here() and piping approach.
here()
filefolder <- here("beiwe-data", "biewe_id", "accelerometer")
files <- dir(filefolder, pattern = "*.csv", full.names = TRUE); files
df <- files %>%
  map(read_csv) %>%
  reduce(rbind)
View(df)

# But can we make it into a function that does not depend on piping
get_accelerometer <- function(accelerometer_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}

# Let's test that function
df <- get_accelerometer(here("beiwe-data", "beiwe_id", "accelerometer"))
View(df)


## Function for preprocessing all accelerometer data for all participants in a data folder:
## ---------------------------------------------------------------------------------------

get_power_state_all <- function(parent_dir, id_position, match_string = "accelerometer/.*csv"){

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

# match_string defaults to "accelerometer/.*csv"
power_df <- get_power_state(parent_dir = "/Users/user/beiwe-data", id_position = 3)

head(power_df)
