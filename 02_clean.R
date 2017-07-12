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
names(projected_app_raw)[names(projected_app_raw) == "Projected (based on assumption of 20,000 wells)"] <- "projected"
names(projected_app_raw)[names(projected_app_raw) == "Region"] <- "nrs_region"
keep_col_proj <- c("nrs_region", "projected")

projected_app <- projected_app_raw %>% 
  select(one_of(keep_col_proj)) %>% 
  mutate(projected = round(projected, digits = 0))


## Clean transition_app_raw ##
## Only keep columns in transition_app necessary for data summaries
keep_col_app <- c("AuthorizationType", "ApplicationDate", "VFCBCOffice", "StatusDescription")

transition_app <- transition_app_raw %>% 
  select(one_of(keep_col_app))

## Add Regions to transition_all df
## Get regions for each office from ATS report
office_regions <- processing_time_raw %>%
  mutate(nrs_region = `Region Name`, VFCBCOffice = `Office Name`) %>% 
  select(nrs_region, VFCBCOffice) %>% 
  group_by(VFCBCOffice, nrs_region) %>% 
  summarise(n = n()) %>% 
  select(-(n))

## Change 'North East' to 'Northeast'
office_regions$nrs_region[office_regions$nrs_region == "North East"] <- "Northeast"

## Region file
# regions <- office_regions %>% 
#   group_by(nrs_region) %>% 
#   summarise(n = n()) %>% 
#   select(-(n))

## Merge nrs_regions into transition_all df
transition_app <- merge(transition_app, office_regions, by = "VFCBCOffice", all.x = TRUE)
  


## Clean transition_lic_raw ##
## Only keep columns in transition_lic necessary for data summaries
keep_col_lic <- c("ApplicationType", "NewExistingUse", "JobStatus", "Region",
                  "PurposeUse", "Volume1000m3y")

transition_lic <- transition_lic_raw %>% 
  select(one_of(keep_col_lic))



## Clean transition_processing_time_raw ##
## Only keep columns in transition_app necessary for data summaries
keep_col_time <- c("Region Name", "Authorization Type", "Authorization Status",
                    "Total Processing Time", "Net Processing Time")

## "Received Date", "Accepted Date", "Rejected Date", "Granted/Offered Date",

processing_time <- processing_time_raw %>% 
  select(one_of(keep_col_time))

## Remove spaces in col names
colnames(processing_time) <- gsub(" ", "_", colnames(processing_time))

## Filter for Existing Groundwater Licenses only
processing_time <- processing_time %>% 
  filter(Authorization_Type == "Existing Groundwater Licence" | Authorization_Type == "New Groundwater Licence") %>% 
  filter(Authorization_Status == "Closed") %>% 
  select(-Authorization_Status)
  



## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app, transition_app, transition_lic, processing_time, 
      app_date, lic_date, proctime_date, office_regions, file = "tmp/trans_gwlic_clean.RData")

