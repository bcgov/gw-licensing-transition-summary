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

#####################
# Data 'as of' DATE #
#####################
## Set the date that the data is current to
ddate <- "April 5th 2018"

###############
# DATA files  #
###############
## These files should be placed in the data/ folder of this directory. See
## data/README.md for details.

## The projected number of transition Existing Use Groundwater License Applications (from ENV Water Branch)
projected_app_raw <- "Projected_GW_Transition_Licences_ENVWaterBranch.xlsx"

## The MS Excel E-licence data for Existing Use Groundwater License Applications provided
## by the Water Management Branch, FLNRORD. This file is updated every 2 weeks.
lic_raw <- "GW_Applications_current.xlsx"

## The join table for FCBC Regions and NRS Regions (from EnvReportBC)
regions <- "regions_matchup.csv"

## Load data files --------------------------
regions <- read.csv(file.path("data", regions), stringsAsFactors = FALSE, 
                    check.names = FALSE)
projected_app_raw <- read_excel(file.path("data", projected_app_raw))
elic_raw <- read_excel(file.path("data", lic_raw), sheet = "e-Lic")
virtual_raw <- read_excel(file.path("data", lic_raw), sheet = "vFCBC")

## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app_raw, regions, elic_raw, virtual_raw, ddate, 
     file = "tmp/trans_gwlic_raw.RData")

