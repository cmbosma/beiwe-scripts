## Beiwe GPS preprocessing
## Colin Bosma

## PACKAGES
## -----------------------------------------------------------------------------

library(here)
library(tidyverse)

## Compiling data for one participant at a time:
## --------------------------------------------

# Using a here() and piping approach.
here()
filefolder <- here("beiwe-data", "abcdefjh", "gps")
files <- dir(filefolder, pattern = "*.csv", full.names = TRUE); files
df <- files %>%
  map(read_csv) %>%
  reduce(rbind)
View(df)

# But can we make it into a function that does not depend on piping
get_gps <- function(gps_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}

# Let's test that function
df <- get_gyro(here("beiwe-data", "abcdefjh", "gps"))
View(df)


## Function for preprocessing all gyro data for all participants in a data folder:
## ---------------------------------------------------------------------------------------

get_gps_all <- function(parent_dir, id_position, match_string = "gps/.*csv"){

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
    })
}

# match_string defaults to "gps/.*csv"
gps_df <- get_gps_all(parent_dir = "/Users/user/beiwe-data", id_position = 5)
head(gps_df)
