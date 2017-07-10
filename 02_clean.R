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



## Clean projected_app_raw ##
## Only keep columns in transition_app necessary for data summaries
names(projected_app_raw)[names(projected_app_raw) == "Projected (based on assumption of 20,000 wells)"] <- "Projected"
keep_col_proj <- c("Region", "Projected")

projected_app <- projected_app_raw %>% 
  select(one_of(keep_col_proj)) %>% 
  mutate(Projected = round(Projected, digits = 0))



## Clean transition_app_raw ##
## Only keep columns in transition_app necessary for data summaries
keep_col_app <- c("AuthorizationType", "ApplicationDate", "StatusDescription")

transition_app <- transition_app_raw %>% 
  select(one_of(keep_col_app))



## Clean transition_appv2_raw ##
## Only keep columns in transition_app necessary for data summaries
keep_col_appv2 <- c("Application Type", "Region", "Purpose Use", "Date Submitted", "Job Status")

transition_appv2 <- transition_appv2_raw %>%
  select(one_of(keep_col_appv2))

## Remove spaces in col names
colnames(transition_appv2) <- gsub(" ", "_", colnames(transition_appv2))

## Filter for Existing Groundwater Licenses only
transition_appv2 <- filter(transition_appv2, Application_Type == "Existing Use Groundwater Application")



## Clean transition_lic_raw ##
## Only keep columns in transition_lic necessary for data summaries
keep_col_lic <- c("ApplicationType", "NewExistingUse", "JobStatus", "Region",
                  "PurposeUse", "Volume1000m3y")

transition_lic <- transition_lic_raw %>% 
  select(one_of(keep_col_lic))



## Clean transition_processing_time_raw ##
## Only keep columns in transition_app necessary for data summaries
keep_col_time <- c("Region Name", "Business Area", "Authorization Type", "Received Date", "Total Processing Time")

processing_time <- processing_time_raw %>% 
  select(one_of(keep_col_time))

## Remove spaces in col names
colnames(processing_time) <- gsub(" ", "_", colnames(processing_time))

## Filter for Existing Groundwater Licenses only
processing_time <- filter(processing_time,
                          Authorization_Type == "Existing Groundwater Licence" | Authorization_Type == "New Groundwater Licence" )



## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app, transition_app, transition_appv2, transition_lic, processing_time, 
      app_date, appv2_date, lic_date, proctime_date, file = "tmp/trans_gwlic_clean.RData")

