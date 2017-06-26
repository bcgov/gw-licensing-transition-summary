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

## Import the data for Existing Use Groundwater License Applications (CSV)
## Data source is a manual export (MS Excel file) from 'FCBC Application Search' via
## Virtual FrontCounter BC E-licensing Home
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 

transition_app_raw <- read_excel("Z:/water/groundwater/licensing/transition/FCBC ApplicationSearch_eASP Jun 19 2017.xlsx")


## Import the data for Existing Use Groundwater Incoming Licenses  (CSV)
## Data source is a manual export (MS Excel file) from 
## 'Incoming Groundwater Licence Application Tracking Report' via
## Virtual FrontCounter BC E-licensing Home
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 

transition_lic_raw <- read_excel("Z:/water/groundwater/licensing/transition/ApplicationPurposeUseSearch Jun 19 2017.xlsx")


## Import the data for Existing Use Groundwater Incoming License Processing Time (CSV)
## Data source is a manual export (MS Excel file) from 
## 'FrontCounterBC ATS system application processing time report' via
## email from FCBA staff (generted monthly)
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 

transition_processing_time_raw <- read_excel("Z:/water/groundwater/licensing/transition/Groundwater Data until May 30, 2017 - run on June 5th .xlsx")

datadate <- "June 19th 2017"

## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(transition_app_raw, transition_lic_raw, datadate,
     transition_processing_time_raw, file = "tmp/trans_gwlic_raw.RData")

