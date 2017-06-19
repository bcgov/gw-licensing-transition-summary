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
library(envreportutils) # order_df


## Load clean data if not already in local repository
if (!exists("transition_app")) load("tmp/trans_gwlic_clean.RData")


## make a 'total transition applications with estimated transitions' dataframe
tot_ta <- length(transition_app$AuthorizationType)
est_ta <- 20000
remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding", "Current Number")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)


## number of applications by application category
ta_type <- transition_app %>% 
  group_by(StatusDescription) %>% 
  summarise(number = length(StatusDescription))

## arranging the order of the categories to be plotted
cat.order <- c("Accepted", "Under Review", "Pending", "Submitted", "Pre-Submittal", 
                "Not Accepted", "Cancelled", "Editing")

## reordering the categories for plotting
ta_type$StatusDescription <- factor(ta_type$StatusDescription, levels = cat.order)


## number of licenses by status category
tl_status <- transition_lic %>% 
  group_by(JobStatus) %>% 
  summarise(number = length(JobStatus))

## Change 'Grant' to 'Granted'
tl_status$JobStatus[tl_status$JobStatus == "Grant"] <- "Granted"

## Subset for plotting only 2 categories
# tl_in_progress <- tl_status %>%
#   filter(JobStatus == "In Progress" | JobStatus == "Granted")

## order tl_in_progress dataframe & change JobStatus Name
tl_status<- order_df(tl_status, target_col = "JobStatus", value_col = "number", fun = max, desc = TRUE)


## calculate number of parked and abandoned 
# tl_parked <- tl_status$number[tl_status$JobStatus == "Parked"]
# tl_abandon <- tl_status$number[tl_status$JobStatus == "Abandoned"]


## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)

save(tot_ta, ta_type, est.df, cat.order, tl_status,
     file = "tmp/trans_gwlic_summaries.RData")
