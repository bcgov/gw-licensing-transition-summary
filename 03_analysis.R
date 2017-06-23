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
library(lubridate)

## Load clean data if not already in local repository
if (!exists("transition_app")) load("tmp/trans_gwlic_clean.RData")


## transition_app summaries ##

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



## transition_lic summaries ##

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


## transition_time summaries ##

## calculate the num applications per date
transition_time_day <- transition_time %>%
  group_by(`Business Area`, `Authorization Type`, `Received Date`) %>% 
  summarise(numperday = n())

## cumlative sum of applications  
transition_time_day$cumsum <- cumsum(transition_time_day$numperday)

## Calculate current rate to-date

appsum <- sum(transition_time_day$numperday)
firstday <- min(transition_time_day$`Received Date`)
lastday <- max(transition_time_day$`Received Date`)
numdays <- as.integer(difftime(as.POSIXct(lastday), as.POSIXct(firstday), units="days"))
current_rate <- appsum/numdays

## Calculate rate forecast bassed on current rate
enddate <- as.POSIXct(as.character("2019-03-01"))
date <- seq(lastday, enddate, by="1 day")
current_rate_forecast <- data.frame(date)
current_rate_forecast$num <- current_rate
current_rate_forecast$num[1] <- appsum
current_rate_forecast$cumsum <- cumsum(current_rate_forecast$num)


## workshop df
# date <- as.POSIXct(c('2016-11-01','2017-03-01'))
# cumsum <- c(179, 802)
# label <- as.character(c("Start of\nWorkshops", "End of \nWorkshops"))
# wrkshops <- data.frame(date, cumsum, label)

## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)

save(tot_ta, ta_type, est.df, cat.order, tl_status,
     transition_time_day, current_rate_forecast, file = "tmp/trans_gwlic_summaries.RData")
