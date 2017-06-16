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
if (!exists("transition_lic")) load("tmp/trans_gwlic_clean.RData")

## make a total applications with estimated total dataframe
tot_ta <- length(transition_lic$AuthorizationType)
est_ta <- 20000
remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding", "Current Number")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)


## number of licenses by application category
ta_type <- transition_lic %>% 
  group_by(StatusDescription) %>% 
  summarise(number = length(StatusDescription))

## arranging the order of the categories to be plotted
cat.order <- c("Accepted", "Under Review", "Pending", "Submitted", "Pre-Submittal", 
                "Not Accepted", "Cancelled", "Editing")

## reordering the categories for plotting
ta_type$StatusDescription <- factor(ta_type$StatusDescription, levels = cat.order)

## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(tot_ta, ta_type, est.df, cat.order,  file = "tmp/trans_gwlic_summaries.RData")
