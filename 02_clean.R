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
if (!exists("projected_app_raw")) load("tmp/trans_gwlic_raw.RData")


## Clean projected_app_raw 
# Change coloumn names, keep only some columns and round estimates to zero sig figs

projected_app_clean <- projected_app_raw %>% 
  rename(Projected = `Projected (based on assumption of 20,000 wells)`,
         nrs_region = Region) %>% 
  select(nrs_region, Projected) %>% 
  mutate(Projected = round(Projected, digits = 0))

## Cross walking the two data frames:
## virtual_raw$Water_Tracking_Number == elic_raw$JobID
## virtual_raw$Date_Accepted == elic_raw$CreatedDate

## Clean virtual_raw

## Remove spaces in col names
colnames(virtual_raw) <- gsub(" ", "_", colnames(virtual_raw))

## Only keep columns in virtual_raw necessary for plots,
## filter out new licence applications and
## filter out duplicate licence using VCFBC_Tracking_Number
keep_col_virtual <- c("Application_Type", "Date_Submitted", "vFCBC_Tracking_Number",
                      "Water_Tracking_Number",  "Job_Status")

virtual_clean <- virtual_raw %>%
  select(one_of(keep_col_virtual)) %>%
  filter(Application_Type == "Existing Use Groundwater Application") %>% 
  distinct(Application_Type, Date_Submitted, vFCBC_Tracking_Number, Water_Tracking_Number, Job_Status, .keepall = TRUE)

## Fix date formatting from character to Date
virtual_clean$Date_Submitted <- as.Date(virtual_clean$Date_Submitted, format = "%m/%d/%Y")


## Clean e-Lic_raw
## Only keep columns in transition_lic necessary for plots, and filter out new licence applications
keep_col_elic <- c("JobID", "TrackingNumber", "ApplicationType", "NewExistingUse", "JobStatus", "Region",
                  "PurposeUse", "Volume1000m3y")

elic_clean_dup <- elic_raw %>% 
  select(one_of(keep_col_elic)) %>% 
  filter(NewExistingUse == "Existing Use")

## Filter our duplicate licence applications using TrackingNumber and columns,
## some plots not useful without those duplicates (e.g. water use types)
## Add NRS regions for comparing with Projected dataframe
elic_clean <- elic_clean_dup %>% 
  select(TrackingNumber, ApplicationType, NewExistingUse, JobStatus, Region) %>% 
  distinct(TrackingNumber, ApplicationType, NewExistingUse, JobStatus, Region,
          .keepall = TRUE) %>% 
  rename(`E-licence Regions` = Region) %>% 
  left_join(regions)


## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(ddate, projected_app_clean, virtual_clean, elic_clean_dup, elic_clean, file = "tmp/trans_gwlic_clean.RData")

