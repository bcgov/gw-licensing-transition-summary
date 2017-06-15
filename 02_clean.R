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
if (!exists("transition_lic_raw")) load("tmp/trans_gwlic_raw.RData")

## clean transition_lic_raw 

## Only keep columns in transition_lic necessary for data summaries
keep_col <- c("AuthorizationType", "ApplicationDate", "StatusDescription", "VFCBCOffice")

transition_lic <- transition_lic_raw %>% 
  select(one_of(keep_col))


## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(transition_lic, file = "tmp/trans_gwlic_clean.RData")

