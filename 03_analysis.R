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
tot_ta <- length(transition_app$StatusDescription)
est_ta <- 20000
remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding", "Current Number")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)


## number of applications by application category
ta_type <- transition_app %>% 
  count(StatusDescription) 

## arranging the order of the categories to be plotted
cat.order <- c("Accepted", "Under Review", "Pending", "Submitted", "Pre-Submittal", 
                "Not Accepted", "Cancelled", "Editing")

## reordering the categories for plotting
ta_type$StatusDescription <- factor(ta_type$StatusDescription, levels = cat.order)


## calculate the num applications per day
transition_time_day <- transition_app %>%
  group_by(ApplicationDate) %>%
  summarise(numperday = n())
mean_rate_per_day <- mean(transition_time_day$numperday)

## What days are people applying
# transition_time_day$day <- wday(as.Date(transition_time_day$ApplicationDate), label=TRUE, abbr = FALSE)
# day_plot <- ggplot(transition_time_day, aes(day, numperday)) +
#   geom_col(alpha = 0.7)
# plot(day_plot)

## cumlative sum of applications and add to df
transition_time_day$cumsum <- cumsum(transition_time_day$numperday)

## Calculate current rate to-date
appsum <- sum(transition_time_day$numperday)
firstday <- min(transition_time_day$ApplicationDate)
lastday <- max(transition_time_day$ApplicationDate)
numdays <- as.integer(difftime(as.POSIXct(lastday), as.POSIXct(firstday), units="days"))
current_rate <- appsum/numdays

## Calculate rate forecast based on current rate and add to df
enddate <- as.POSIXct(as.character("2019-03-01"))
date <- seq(lastday, enddate, by="1 day")
rate_forecasts <- data.frame(date)
rate_forecasts$curr_num <- current_rate
rate_forecasts$curr_num[1] <- appsum
rate_forecasts$curr_cumsum <- cumsum(rate_forecasts$curr_num)

## Calculate the required rate for March 2019 end date and add to df
app_to_go <- est_ta - appsum
days_to_go <- as.integer(enddate - lastday)
rate_to_achieve <- app_to_go/days_to_go
rate_forecasts$req_num <- rate_to_achieve
rate_forecasts$req_num[1] <- appsum
rate_forecasts$req_cumsum <- cumsum(rate_forecasts$req_num)

## Calculate the required rate for March 2019 end date for workdays only
work_days_to_go <- sum(!weekdays(seq(lastday, enddate, "days")) %in% c("Saturday", "Sunday"))
work_day_rate_to_achieve <- app_to_go/work_days_to_go

## workshop df
# date <- as.POSIXct(c('2016-11-01','2017-03-01'))
# cumsum <- c(179, 802)
# label <- as.character(c("Start of\nWorkshops", "End of \nWorkshops"))
# wrkshops <- data.frame(date, cumsum, label)



## transition_lic summaries ##
## number of licenses by status category
tl_status <- transition_lic %>% 
  group_by(JobStatus) %>% 
  summarise(number = length(JobStatus))

## Change 'Grant' to 'Granted'
tl_status$JobStatus[tl_status$JobStatus == "Grant"] <- "Granted"

## arranging the order of the categories to be plotted
cat.order2 <- c("Granted", "In Progress", "Parked")

## reordering the categories for plotting
tl_status$JobStatus <- factor(tl_status$JobStatus, levels = cat.order2)



## transition_time summaries ##



## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)

save(tot_ta, ta_type, est.df, cat.order, tl_status,
     transition_time_day, rate_forecasts,  app_date, lic_date, proctime_date,
     current_rate, rate_to_achieve, lastday,
     work_day_rate_to_achieve, file = "tmp/trans_gwlic_summaries.RData")
