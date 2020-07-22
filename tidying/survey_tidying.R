## Beiwe Survey Tidying
## Colin Bosma


## RESOURCES
## -----------------------------------------------------------------------------

# Github for RegExplain addin for creating regular expressions
browseURL("https://github.com/gadenbuie/regexplain")


## PACKAGES
## -----------------------------------------------------------------------------

library(stringr) # for manipulating strings
library(rebus) # for easy regular expressions
library(tidyverse)
library(lubridate)


## Tidying issue 1: iOS devices, entry for each character change in text-entry questions
## -----------------------------------------------------------------------------

# Basic work flow to remove extra entries preceding full entry
# Notes:
  # On iOS devices, there is an 'even' column. We want to drop every case where 'event' == "changed"
    # To isolate just the open-ended, text response items, we want to also only include those questions

surveys_df <- surveys_df %>%
  filter(!(`question text` == "<question text>" & event == "changed" ))

# Test tidying iOS surveys

# Make a small subset of rows from a device running iOS
df_sub_ios <- df[1:35,]

test_df <- df_sub_ios %>%
  filter(!(`question text` == "<question text>" & event == "changed"))

# Tidying issue 2: Android devices, duplicate entries for each "what are you currently doing"
## -----------------------------------------------------------------------------

# Notes:
  # the Lubridate package is needed to convert UTC time to seconds.
  # dplyr::lag() is used with seconds to identify problematic duplicates.

# For testing out work flows
# make sure you are pulling from a participant with an Android phone
df_sub_and <- df[1:15,]


## This work flow identifies problematic duplicates
  # Unfortunately, it cuts out the other rows that we need. Helpful for reviewing.

surveys_df %>%
  group_by(`question text`) %>%
  filter(second(`UTC time`) - lag(second(`UTC time`), 1) < abs(1))

# Next, can remove duplicates by `answer`. Helpful for determining how many you need to remove.

surveys_df %>%
  group_by(`question text`) %>%
  filter(second(`UTC time`) - lag(second(`UTC time`), 1) < abs(1)) %>%
  distinct(answer, .keep_all = TRUE) %>%
  select(`UTC time`, `question text`, answer)

# Test it out
test_df <- df_sub_and %>%
  group_by(`question text`) %>%
  filter(second(`UTC time`) - lag(second(`UTC time`), 1) < abs(1)) %>%
  distinct(answer, .keep_all = TRUE) %>%
  select(`UTC time`, `question text`, answer)

test_df



## Work flow for dropping problematic duplicate cases from text entry items
# Notes:
  # Since participants may enter the same thing at a later time, we can't use the conventional way of removing duplicates
  # Instead, we identify duplicates by time and group by answer to leave one entry

# Create a column to identify duplicates
surveys_df <- surveys_df %>%
  # Convert UTC time to seconds and save to a new column
  mutate(seconds = lubridate::second(`UTC time`)) %>%
  group_by(answer) %>%
  # Tag duplicate entries within less than a second. Do this by answer so not all are tagged.
  mutate(dups = ifelse(
    seconds - lag(seconds, 1) < abs(1),
    "duplicate", NA))

# Filter out rows with duplicates, keep "User hit submit" row to keep things clean.
surveys_df %>%
  filter(is.na(dups) | `question id` == "User hit submit")


# Test it out
test_df <- df_sub_and %>%
  mutate(seconds = lubridate::second(`UTC time`)) %>%
  group_by(answer) %>%
  mutate(dups = ifelse(
    seconds - lag(seconds, 1) < abs(1),
    "duplicate", NA))
test_df
test_df %>%
  filter(is.na(dups) | `question id` == "User hit submit")
