# Introduction

`beiwe-scripts` is a repository for R and Python scripts for processing, tidying, and analyzing data from the open-access deployment version of the [Beiwe research platform](https://www.beiwe.org/). This repository is in the early stages of development and meant to be used in a modular fashion.


# Table of Contents
   * [Usage](#usage)
   * [Processing](#processing)
      * [Power State](#power-state)
      * [Accelerometer](#accelerometer)
      * [Gyro](#gyro)
      * [GPS](#gps)
      * [Surveys](#surveys)
   * [Tidying](#tidying)
      * [Time](#time)
      * [Surveys](#surveys)

# Usage

The processing scripts are working from raw beiwe data downloaded using the beiwe research platform download API. The data file path structure is assumed to be the following: data/BeiweID-folders/data-type-folders/.csv

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

**Example Usage**
```R
df <- get_power_state(mypath = "<path-to-power_state>", beiweID = "<beiweID-data-folder-name>")
df <- get_power_state(mypath = "~.power_state", beiweID = "abcdefjh")
```

The `get_power_state_all` function combines all power state data for every individual in a data folder. It also creates a Beiwe ID column. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/data/<beiwe-data-folders>`, the `id_position` argument should equal 5.

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
df <- get_power_state_all(parent_dir = "<path-to-data-folder>", id_position = 5)
```

## Accelerometer

**Packages**

```R
library(here)
library(tidyverse)
```

The `get_accelerometer` function combines all of the accelerometer data for one individual into one data frame. The `accelerometer_filefolder` argument should be the path to the folder containing the accelerometer data files. Either enter the directory in quotes or use a here() approach (see example usage).

```R
get_accelerometer <- function(accelerometer_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}
```

**Example Usage**
```R
df <- get_accelerometer(here("beiwe-data", "beiwe_id", "accelerometer"))
head(df)
```
The `get_accelerometer_all` function combines all power state data for every individual in a data folder. It also creates a Beiwe ID column. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/beiwe-data/<beiwe-data-folders>`, the `id_position` argument should equal 5.

```R
get_accelerometer_all <- function(parent_dir, id_position, match_string = "accelerometer/.*csv"){

  #recursively search ALL directories for files,
  #only return relative path of files that match "accelerometer/<stuff>csv"
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
```

**Example Usage**
```R
# match_string defaults to "accelerometer/.*csv"
accelerometer_df <- get_accelerometer_all(parent_dir = "/Users/user/beiwe-data", id_position = 5)
head(accelerometer_df)
```

## Gyro
**Packages**

```R
library(here)
library(tidyverse)
```

The `get_gyro` function combines all of the accelerometer data for one individual into one data frame. The `gyro_filefolder` argument should be the path to the folder containing the accelerometer data files. Either enter the directory in quotes or use a here() approach (see example usage).

```R
get_gyro <- function(gyro_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}
```

**Example Usage**
```R
df <- get_gyro(here("beiwe-data", "beiwe_id", "gyro"))
head(df)
```
The `get_gyro_all` function combines all power state data for every individual in a data folder. It also creates a Beiwe ID column. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/beiwe-data/<beiwe-data-folders>`, the `id_position` argument should equal 5.

```R
get_gyro_all <- function(parent_dir, id_position, match_string = "gryo/.*csv"){

  #recursively search ALL directories for files,
  #only return relative path of files that match "gyro/<stuff>csv"
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
```

**Example Usage**
```R
# match_string defaults to "gyro/.*csv"
gyro_df <- get_gyro_all(parent_dir = "/Users/user/beiwe-data", id_position = 5)
head(gyro_df)
```

## GPS

**Packages**

```R
library(here)
library(tidyverse)
```

The `get_gps` function combines all of the accelerometer data for one individual into one data frame. The `gps_filefolder` argument should be the path to the folder containing the accelerometer data files. Either enter the directory in quotes or use a here() approach (see example usage).

```R
get_gps <- function(gps_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}
```

**Example Usage**
```R
df <- get_gps(here("beiwe-data", "beiwe_id", "gps"))
head(df)
```
The `get_gyro_all` function combines all power state data for every individual in a data folder. It also creates a Beiwe ID column. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/beiwe-data/<beiwe-data-folders>`, the `id_position` argument should equal 5.

```R
get_gyro_all <- function(parent_dir, id_position, match_string = "gps/.*csv"){

  #recursively search ALL directories for files,
  #only return relative path of files that match "gyro/<stuff>csv"
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
```

**Example Usage**
```R
# match_string defaults to "gps/.*csv"
gyro_df <- get_gps_all(parent_dir = "/Users/user/beiwe-data", id_position = 5)
head(gps_df)
```

**Further Processing GPS data**

[coming soon]

## Surveys

**Packages**

```R
library(here)
library(tidyverse)
```

The `get_survey` function combines all of the survey data for one individual into one data frame. The `surveyID_filefolder` argument should be the path to the folder labeled with the survey ID that contains the survey data files. Either enter the directory in quotes or use a here() approach (see example usage).


```R
get_survey <- function(surveyID_filefolder) {
  files = dir(filefolder, pattern = "*.csv", full.names = TRUE)
  temp_df = map(files, read_csv)
  df = reduce(temp_df, rbind)
}
```

If you have multiple surveys that are being deployed, then you will want to combine them using `dplyr::bind_rows(df1, df2, ...))`. Next, make sure the data is in chronological order. Below is a code snippet to accomplish just that.

```R
dplyr::bind_rows(df1, df2, df3, ...)

df <- df %>%
  group_by(`survey id`) %>%
  arrange(`UTC time`)
```

**Example Usage**
```R
df <- get_survey(here("survey_timings", "<survey ID>"))
# Arrange by chronological order, if needed
df <- df %>%
  group_by(`survey id`) %>%
  arrange(`UTC time`)
# Check your work
View(df)
```


The `get_surveys_all` function combines all survey data for every individual in a data folder. It also creates a Beiwe ID column and orders the data by time according to Beiwe ID and survey ID. The directory for the `parent_dir` argument the parent directory should be assigned as the data folder holding all of the individual data folders. However, the `id_position` argument allows you enter where in your file path to direct the function to get the Beiwe IDs from the names of the individual data folders. The `id_position` argument should equal the level of the parent folder of the individual data folders. For example, a file path such as `Users/projects/beiwe-data/<beiwe-data-folders>`, the `id_position` argument should equal 5.

```R
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
```

**Example Usage**

```R
surveys_df <- get_surveys_all(parent_dir = "<path_to_data>", id_position = 6)
head(surveys_df)
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
# Otherwise, use `UTC time`
df <- df %>%
  dplyr::rename("UTCtime" = "UTC time")
```

R Studio should recognize that `UTC time` is a date-time variable and that it is in ymd_hms format (i.e., year/month/day hour:minute:second).
If needed, convert "UTC time" to date-time variable:

```R
df <- df %>%
  ymd_hms(`UTC time`, tz = "UTC")
```

Setting UTC time to specified time zone:
```R
OlsonNames() # List valid time zone names
df <- df %>%
  ymd_hms(`UTC time`, tz = "US/Eastern")
```

Add a new date-time variable with a different time zone:
```R
df <- df %>%
  mutate(UTCtime_EST = with_tz(`UTC time`, tz = "US/Eastern"))
```

Separating UTC time into separate date and time columns:
```R
df <- df %>%
  separate(`UTC time`, c("date", "time"), sep = " ")
```

Convert `timestamp` to UTC date-time variable.
```R
df <- df %>%
  # divide by 1000 so that the as_datetime() can convert the timestamp variable
  mutate(timestamp = timestamp/1000) %>%
  mutate(timestamp_dt = as_datetime(timestamp, tz = "UTC"))
```

## Surveys

Surveys deployed by the Beiwe research platform are going to be unique to the user. This section provides some tidying approaches that can be generally applied to Beiwe survey data.

Using the Beiwe Research Platform single-server deployment API, iOS devices and Android devices provide survey output in slightly different formats.
- **iOS devices**: For text-entry data, there is a new row for each change in character, creating many rows for one answer on a survey. Luckily, there is an `event` column to help use remove the extra entries.
- **Android devices**: For text-entry data, there are sometimes duplicate entries. Duplicate rows are typically easy to tidy up (e.g., dplyr::distict()). However, these are unique cases due to the time stamps. Also, a participant my provide the same answer at a later time and date, so we can't remove duplicates solely using the `answer` vector.

Below are tidying work flows to address these two problems.


**Packages**

```R
library(tidyverse)
library(lubridate)
```

**iOS Survey Data**

```R
# Filter out the questions that correspond with "changed" in the `event` vector
surveys_df <- surveys_df %>%
  filter(!(`question text` == "<question text>" & event == "changed" ))
```

**Android Survey Data**

The code snippet below identifies problematic duplicates, which is helpful for reviewing. Unfortunately, it cuts out the other rows that we need.

```R  
surveys_df %>%
  group_by(`question text`) %>%
  filter(second(`UTC time`) - lag(second(`UTC time`), 1) < abs(1))
```
As mentioned above, functions for identifying and removing duplicates will not have the desired effect (e.g., distinct(), unique(), duplicated()), as these approaches may remove text entries matching text at different time points. The code snippet below filters out the unwanted duplicate entries from text-entry questions without removing same-text entries at different time points. Given the duplicates occur in less than a second, we can use the `UTC time` vector to identify the duplicate entries within a one-second time frame, and by answer, to reduce the entries to one occurrence.

```R
# Create a column to identify duplicates
surveys_df <- surveys_df %>%
  # Convert UTC time to seconds and save to a new column
  mutate(seconds = lubridate::second(`UTC time`)) %>%
  group_by(answer) %>%
  # Tag duplicate entries within less than a second. Do this by answer so not all are tagged.
  mutate(dups = ifelse(
    seconds - lag(seconds, 1) < abs(1),
    "duplicate", NA))
```
