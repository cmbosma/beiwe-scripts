## Time tidying for Beiwe data 

## Libraries
library(lubridate)
library(tidyverse)
library(dplr)

## RESOURCES
## -----------------------------------------------------------------------------

# Lubridate cheatsheet
browseURL("https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf")

# Base R documentation for creating date-time variables
browseURL("https://stat.ethz.ch/R-manual/R-devel/library/base/html/as.POSIXlt.html")

# List valid time zone names
OlsonNames() 

## TIME TIDYING BEIWE DATA
## -----------------------------------------------------------------------------

# First, if needed, change the name of the "UTC time" variable
df <- df %>% 
  dplyr::rename("UTCtime" = "UTC time")

# R should recognize that UTC time is a date-time variable. It is in ymd_hms format
# If needed, convert "UTC time" to date-time variable: 
df <- df %>%
  ymd_hms(UTCtime, tz = "UTC")

# Setting UTC time to specified time zone
OlsonNames() # List valid time zone names

df <- df %>%
  ymd_hms(df$UTCtime, tz = "US/Eastern")

# Add a new date-time variable with a different time zone
df$time_EST <- with_tz(df$UTCtime, "US/Eastern")

# Separating UTC time into separate date and time columns
df <- df %>%
  separate("UTC time", c("date", "time"), sep = " ")
head(df[, "data","time"], 10)

# Convert time stamp to UTC date-time variable

df <- df %>% 
  mutate(timestamp = timestamp/1000) %>%
  mutate(timestamp_dt = as_datetime(timestamp, tz = "UTC"))

power_df$timestamp_dt <- as_datetime(power_df$timestamp_c, tz = "UTC")
