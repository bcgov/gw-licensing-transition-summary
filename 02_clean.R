# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

library(dplyr) # data munging

## Load raw data if not already in local repository
if (!exists("transition_app_raw")) load("tmp/trans_gwlic_raw.RData")

## clean transition_app_raw ##

## Only keep columns in transition_app necessary for data summaries
keep_col_app <- c("Application Type", "Region", "Purpose Use", "Date Submitted", "Job Status")

transition_app <- transition_app_raw %>% 
  select(one_of(keep_col_app))

## filter for Existing Groundwater Licenses only
transition_app <- filter(transition_app, `Application Type` == "Existing Use Groundwater Application")


## clean transition_lic_raw ##

## Only keep columns in transition_lic necessary for data summaries
keep_col_lic <- c("ApplicationType", "NewExistingUse", "JobStatus", "Region",
                  "PurposeUse", "Volume1000m3y")

transition_lic <- transition_lic_raw %>% 
  select(one_of(keep_col_lic))


## clean transition_processing_time_raw ##

## Only keep columns in transition_app necessary for data summaries
keep_col_time <- c("Region Name", "Business Area", "Authorization Type", "Received Date")

transition_time <- transition_processing_time_raw %>% 
  select(one_of(keep_col_time))

## filter for Existing Groundwater Licenses only
transition_time <- filter(transition_time, `Authorization Type` == "Existing Groundwater Licence")


## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(transition_app, transition_lic, transition_time, datadate,
     file = "tmp/trans_gwlic_clean.RData")

