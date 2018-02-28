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


## PATHS
## ENV SoE Unit soe_data source PATH
# path <- "~/soe_data/water/groundwater/licensing/transition/"

## ENV Water data source PATH
path <- "C:/R Projects/gw-licensing-transition-summary/Data/"


## DATA files
## The projected number of transition Existing Use Groundwater License Applications (from ENV Water Branch)
projected_app_raw <- "Projected_GW_Transition_Licences_ENVWaterBranch.xlsx"

## The join table for FCBC Regions and NRS Regions (from EnvReport BC)
regions <- "regions_matchup.xlsx"

## The MS Excel E-licence data for Existing Use Groundwater License Applications provided
## by a Senior Water Business Specialist in the Water Management Branch, FLNRO
## This file is updated every 2 weeks, sent to Greg Tyson, who forwards to us analysts to produce this report.
## The data should be saved here Z:\WPS\Water Strategies\Groundwater Licensing - BIG project\GW Licencing Data 
## (Heather worked off her C drive so that's where she saved a copy of the data which is where the path below is from)
lic_raw <- "GW Applications Feb 22, 2018.xlsx"


## Data 'as of' DATE
ddate <- "February 22nd 2018"


## Load data files
regions <- read_excel(paste0(path, regions))
projected_app_raw <- read_excel(paste0(path, projected_app_raw))
elic_raw <- read_excel(paste0(path, lic_raw), sheet = "e-Lic")
virtual_raw <- read_excel(paste0(path, lic_raw), sheet = "FCBC")


## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app_raw, regions, elic_raw, virtual_raw, ddate, 
     file = "tmp/trans_gwlic_raw.RData")

