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


library(readxl) # MS Excel data import 


## Import the projected number of transition Existing Use Groundwater License Applications (from ENV Water Branch)
projected_app_raw <- read_excel("~/soe_data/water/groundwater/licensing/transition/Projected_GW_Transition_Licences_ENVWaterBranch.xlsx")

## Import the join table for FCBC Regions and NRS Regions (from EnvReport BC)
regions <- read_excel("~/soe_data/water/groundwater/licensing/transition/regions_matchup.xlsx")


## Import the projected number of transition Existing Use Groundwater License Applications (from ENV Water Branch)
projected_app_raw <- read_excel("~/soe_data/water/groundwater/licensing/transition/Projected_GW_Transition_Licences_ENVWaterBranch.xlsx")

## Import the join table for FCBC Regions and NRS Regions (from EnvReport BC)
regions <- read_excel("~/soe_data/water/groundwater/licensing/transition/regions_matchup.xlsx")


## Import the E-licence data for Existing Use Groundwater License Applications
## Data source is a MS Excel file export provided by a 
## Senior Water Business Specialist in the Water Management Branch, FLNRO
elic_raw <- read_excel("~/soe_data/water/groundwater/licensing/transition/GW Applications Nov 1, 2017.xlsx", sheet = "e-Lic")
virtual_raw <- read_excel("~/soe_data/water/groundwater/licensing/transition/GW Applications Nov 1, 2017.xlsx", sheet = "virtual")

## Data 'as of' date
ddate <- "November 1st 2017"


## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app_raw, regions, elic_raw, virtual_raw, ddate, 
     file = "tmp/trans_gwlic_raw.RData")

