# Introduction
---

`beiwe-scripts` is a repository for R and Python scripts for processing, tidying, and analyzing data from the open-access deployment version of the [Beiwe research platform](https://www.beiwe.org/). This repository is in the early stages of development and meant to be used in a modular fashion.


# Table of Contents
---

# Usage

The processing scripts are working from raw beiwe data downloaded using the beiwe research platform download API. The data structure is assumed to be the following: data/BeiweID-folders/data-type-folders/.csv

The R scripts are written under the assumption that your workflow implements the `here` R package for handling your relative paths in your project. Alternatively, you can use the scripts using your full file path.

`df` consistently refers to your data, or data frame.

# Processing

## Power State

**Packages**

`library(here)
library(tidyverse)`

The `get_power_state` function combines all of the power state data for one individual into one data frame. The `beiweID` arguement allows you to enter the Beiwe ID of the individual to generate a "bewiweID" column. The Beiwe ID is repeated for the number of rows of the data frame as the data is in long format.

`get_power_state <- function(mypath, beiweID){
myfiles = list.files(path = mypath, pattern = "*.csv", full.names = TRUE)
tempDF = plyr::ldply(myfiles, read_csv)
beiweID = rep(beiweID, length.out = tempDF)
newDF = cbind(beiweID, tempDF)
}`

Example usage
`df <- get_power_state(mypath = "<path-to-power_state>", beiweID = "<beiweID-data-folder-name>")
df <- get_power_state(mypath = "~.power_state", beiweID = "abcdefjh"`


# Tidying
