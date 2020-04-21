# Introduction

`beiwe-scripts` is a repository for R and Python scripts for processing, tidying, and analyzing data from the open-access deployment version of the [Beiwe research platform](https://www.beiwe.org/). This repository is in the early stages of development and meant to be used in a modular fashion.


# Table of Contents


# Usage

The processing scripts are working from raw beiwe data downloaded using the beiwe research platform download API. The data structure is assumed to be the following: data/BeiweID-folders/data-type-folders/.csv

The R scripts are written under the assumption that your workflow implements the `here` R package for handling your relative paths in your project. You can, however, use the scripts with your full file path.

`df` consistently refers to your data, or data frame.

# Processing

## Power State

**Packages**

```R
library(here)
library(tidyverse)
```

The `get_power_state` function combines all of the power state data for one individual into one data frame. The `beiweID` argument allows you to enter the Beiwe ID of the individual to generate a "bewiweID" column. The Beiwe ID is repeated for the number of rows of the data frame as the data is in long format.

```R
get_power_state <- function(mypath, beiweID){
myfiles = list.files(path = mypath, pattern = "*.csv", full.names = TRUE)
tempDF = plyr::ldply(myfiles, read_csv)
beiweID = rep(beiweID, length.out = tempDF)
newDF = cbind(beiweID, tempDF)
}
```

**Example usage**
```R
df <- get_power_state(mypath = "<path-to-power_state>", beiweID = "<beiweID-data-folder-name>")
df <- get_power_state(mypath = "~.power_state", beiweID = "abcdefjh")
```

The `get_power_state_all` function combines all power state data for every individual in a data folder. It also creates a Beiwe ID column. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/data/<beiwe-data-folders>`, the `id_position` argument should equal 3.

```R
get_power_state_all <- function(parent_dir, id_position, match_string = "power_state/.*csv"){

  #recursively search ALL directories for files,
  #only return relative path of files that match "power_state/<stuff>csv"
  all_files <- list.files(parent_dir, recursive = T, full.names = TRUE)[grep(pattern = match_string, list.files(parent_dir, recursive = T))]

  #returns data frame of ALL files in the all_files vector.
  #adds beiweID as new column extracted from the input file.
  all_files %>%
    map_df(~{
      read_delim(.x, delim = ",")  %>%
        mutate(beiweID = str_split(.x, pattern = "/", simplify = TRUE)[id_position]) # id_position = level of directory with BeiweID data
    })
}
```

**Example usage**
```R
df <- get_power_state_all(parent_dir = "<path-to-data-folder>", id_position = 2)
```

# Tidying

## Time

The raw data files from the Beiwe research platform typically have `timestamp` or `UTC Time` variables. Here are a few helpful lines of code to work with the time data from Beiwe.

**Packages**
The `lubridate` R package is a very flexible package for working with time variables. It is notable, however, that even though `lubridate` is developed by the Tidyverse team, it does not always play well with some of the Tidyverse conventions. If piping (i.e., %>%) does not work, you can run the code in a a base R format.

```R
library(lubridate)
# Lubridate cheatsheet
browseURL("https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf")
library(tidyverse)
library(dplyr)
```

Since R does not play nice with variable names that have spaces in them, you may want to remove the space from the variable `UTCtime`
```R
# First, if needed, change the name of the "UTC time" variable
df <- df %>%
  dplyr::rename("UTCtime" = "UTC time")
```

R Studio should recognize that `UTC time` is a date-time variable and that it is in ymd_hms format (i.e., year/month/day hour:minute:second).
If needed, convert "UTC time" to date-time variable:

```R
df <- df %>%
  ymd_hms(UTCtime, tz = "UTC")
```

Setting UTC time to specified time zone:
```R
OlsonNames() # List valid time zone names
df <- df %>%
  ymd_hms(df$UTCtime, tz = "US/Eastern")
```

Add a new date-time variable with a different time zone:
```R
df <- df %>%
  mutate(UTCtime_EST = with_tz(UTCtime, tz = "US/Eastern"))
```

Separating UTC time into separate date and time columns:
```R
df <- df %>%
  separate("UTC time", c("date", "time"), sep = " ")
```

Convert `timestamp` to UTC date-time variable.
```R
df <- df %>%
  # divide by 1000 so that the as_datetime() can convert the timestamp variable
  mutate(timestamp = timestamp/1000) %>%
  mutate(timestamp_dt = as_datetime(timestamp, tz = "UTC"))
```
