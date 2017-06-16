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


library(readr) # data import 

## Import the data for Existing Use Groundwater License Applications (CSV)
## Data source is a manual export (MS Excel file) from 'Application Search' on
## Virtual FrontCounter BC E-licensing Home
## XLS converted to CSV and stored in local Data directoy
## Data license: Access Only http://www2.gov.bc.ca/gov/content/home/copyright 

transition_app_raw <- read_csv("Z:/water/groundwater/licensing/transition/ApplicationSearch_eASP.csv")




#transition_lic_raw <- read_csv("Z:/water/groundwater/licensing/transition/Incoming Groundwater License Application Tracking Report.csv.csv")

## Create tmp folder if not already there and store raw data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(transition_app_raw, file = "tmp/trans_gwlic_raw.RData")