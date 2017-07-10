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


## Import the projected number of transition Existing Use Groundwater License Applications
projected_app_raw <- read_excel("Z:/water/groundwater/licensing/transition/Projected_GW_Transition_Licenses_ENVWaterBranch.xlsx")


## Import the APPLICATION data for Existing Use Groundwater License Applications
## Data source is a MS Excel file export from 'FCBC Application Search' 
## provided by email from FLNRO staff (generated on demand)
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 
transition_app_raw <- read_excel("Z:/water/groundwater/licensing/transition/Applications Summary.xlsx")
## Data as of date
app_date <- "June 30th 2017"


## Import the LICENSING data for Existing Use Groundwater Incoming Licenses
## Data source is a MS Excel file report/export from
## 'Incoming Groundwater Licence Application Tracking Report' through
## Virtual FrontCounter BC E-licensing Home, generated manually by ENV staff
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 
transition_lic_raw <- read_excel("Z:/water/groundwater/licensing/transition/ApplicationPurposeUseSearch.xlsx")
## Data as of date
lic_date <- "July 10th 2017"


## Import the PROCESSING TIME data for Existing Use Groundwater Incoming Licensing
## Data source is a MS Excel file export from FCBC's 
## 'FrontCounterBC ATS system application processing time report' provided by
## email from FCBC FLNRO staff (generated monthly)
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 
processing_time_raw <- read_excel("Z:/water/groundwater/licensing/transition/GroundWater-June2017.xlsx")
## Data as of date
proctime_date <- "June 30th 2017"


## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(projected_app_raw, transition_app_raw, transition_lic_raw,
     processing_time_raw, app_date, lic_date, proctime_date,
     file = "tmp/trans_gwlic_raw.RData")

