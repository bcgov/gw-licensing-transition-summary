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
library(tidyr) # reshape df
library(scales) # percent()
library(tibble) # rownames_to_column()
library(ggplot2)
library(envreportutils) # theme_soe()
library(stringr) # for label wrapping

## Load clean data if not already in local repository
if (!exists("transition_app")) load("tmp/trans_gwlic_clean.RData")



## virtual data summaries

## @knitr virtual_status

## collapse some categories for plotting
virtual_clean$Job_Status[virtual_clean$Job_Status == "Cancelled"] <-  "Cancelled & Not Accepted"
virtual_clean$Job_Status[virtual_clean$Job_Status == "Not Accepted"] <-  "Cancelled & Not Accepted"
virtual_clean$Job_Status[virtual_clean$Job_Status == "Editing"] <-  "Submitted & Pre-Review Steps"
virtual_clean$Job_Status[virtual_clean$Job_Status == "Submitted"] <-  "Submitted & Pre-Review Steps"
virtual_clean$Job_Status[virtual_clean$Job_Status == "Pending"] <-  "Submitted & Pre-Review Steps"
virtual_clean$Job_Status[virtual_clean$Job_Status == "Pre-Submittal"] <-  "Submitted & Pre-Review Steps"

## number of applications by application category
ta_type <- virtual_clean %>% 
  count(Job_Status) 

## arranging the order of the categories to be plotted
cat.order <- c("Under Review", "Submitted & Pre-Review Steps", "Cancelled & Not Accepted")

## reordering the categories for plotting
ta_type$Job_Status <- factor(ta_type$Job_Status, levels = cat.order)

## set colour palette
colours <- c("Accepted" = "#e41a1c",
             "Under Review" = "#377eb8",
             "Submitted & Pre-Review Steps" = "#4daf4a",
             "Cancelled & Not Accepted" = "#a65628")

## bar chart of CURRENT applications into VFCBC by status description (does not include accepted applications)
ta_type_plot <- ggplot(ta_type, aes(1, y = n, fill = Job_Status)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FrontCounter BC Transition\nApplication Intake Process") +
  scale_fill_manual(values = colours, name = NULL, breaks = rev(levels(ta_type$Job_Status))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), labels = scales::comma) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=7),
        legend.position = "bottom",
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

plot(ta_type_plot)


## elic data summaries

## number of e-licenses by status category with duplicate rows removed
tl_status <- elic_clean %>% 
  group_by(JobStatus) %>% 
  summarise(number = length(JobStatus))

## Change 'Grant' to 'Granted'
tl_status$JobStatus[tl_status$JobStatus == "Grant"] <- "Decision"

## arranging the order of the categories to be plotted
cat.order3 <- c("Decision", "In Progress", "Parked", "Abandoned")

## reordering the categories for plotting
tl_status$JobStatus <- factor(tl_status$JobStatus, levels = cat.order3)


## colour palette
colr2 <- c("Abandoned" = "#a65628",
           "Parked" = "#4daf4a",
           "In Progress" = "#377eb8",
           "Decision" = "#e41a1c")

## bar chart of incoming E-licence applications by status
tl_status_plot <- ggplot(tl_status, aes(1, y = number, fill = JobStatus)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FLNRO Adjudication: Transition Applications") +
  scale_fill_manual(values = colr2, name = NULL,
                    breaks = rev(levels(tl_status$JobStatus))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0)) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size=10),
        plot.title = element_text(size = 12,  hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

plot(tl_status_plot)




## make a 'total transition applications with estimated transitions' dataframe
tot_ta <- length(transition_app$StatusDescription)
est_ta <- 20000
remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding", "Current Number")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)



## Rate of applications
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

## Number applications and predicted number by Region
tl_region <- transition_lic %>%
  distinct(TrackingNumber, .keep_all = TRUE) %>% 
  group_by(nrs_region) %>%
  summarise(accepted = n() , granted = sum(JobStatus == "Grant")) %>%
  merge(projected_app, by = "nrs_region", all.y=TRUE) %>%
  gather(type, value, -nrs_region) %>%
  mutate(value = ifelse(is.na(value), 0, value))

## arranging the order of the categories to be plotted
cat.order2 <- c("projected", "accepted", "granted")

## reordering the categories for plotting
tl_region$type <- factor(tl_region$type, levels = cat.order2)

## order df for plotting
tl_region<- order_df(tl_region, target_col = "nrs_region", value_col = "value", fun = max, desc = TRUE)



## number of licenses by purpose use category, includes duplicate IDs
tl_purpose <- transition_lic %>% 
  group_by(PurposeUse) %>% 
  summarise(number = length(PurposeUse)) %>% 
  mutate(perc_tot = paste0(round((number/sum(number)*100), digits = 0),"%"))

tl_purpose <- order_df(tl_purpose, target_col = "PurposeUse", value_col = "number", fun = max, desc = TRUE)



## transition_time summaries ##

## Number decisions and avg days and net avg days df
time_region <- processing_time %>% 
  filter(Authorization_Status == "Closed") %>% 
  select(-Authorization_Status) %>% 
  group_by(nrs_region, Authorization_Type) %>%
  summarise(num_dec = n(),
            avg_tot_time = round(mean(Total_Processing_Time), digits = 0),
            avg_net_time = round(mean(Net_Processing_Time), digits = 0),
            diff_time = round(mean(Total_Processing_Time-Net_Processing_Time), digits = 0)) %>%
  ungroup() %>% 
  gather(measure, value, -nrs_region, -Authorization_Type, -num_dec) %>% 
  complete(nrs_region, Authorization_Type, measure, fill = list(value = 0)) %>% 
  mutate(num_dec = ifelse(is.na(num_dec), 0, num_dec)) 


## Throughput rates for recieved, accepted and decisions using processing time report

## calculate the num recieved applications per day
proc_time_rec <- processing_time %>%
  filter(Authorization_Type == "Existing Groundwater Licence") %>% #  Authorization_Status == "Closed"
  group_by(Received_Date) %>%
  summarise(recperday = n()) %>%
  mutate(reccumsum =  cumsum(recperday), Date = Received_Date)

## Calculate received rate to-date starting March 2016
recsum <- sum(proc_time_rec$recperday)
recnumdays <- as.integer(difftime(as.POSIXct(max(proc_time_rec$Received_Date)), as.POSIXct(min(proc_time_rec$Received_Date)), units="days"))
rec_rate <- recsum/recnumdays

## calculate the num accepted applications per day
proc_time_acc <- processing_time %>%
  filter(Authorization_Type == "Existing Groundwater Licence", !is.na(Accepted_Date)) %>% #  Authorization_Status == "Closed"
  group_by(Accepted_Date) %>%
  summarise(accperday = n()) %>% 
  mutate(acccumsum =  cumsum(accperday), Date = Accepted_Date)

## Calculate received rate to-date starting March 2016
accsum <- sum(proc_time_acc$accperday)
accnumdays <- as.integer(difftime(as.POSIXct(max(proc_time_acc$Accepted_Date)), as.POSIXct(min(proc_time_acc$Accepted_Date)), units="days"))
acc_rate <- accsum/accnumdays

## calculate the num decisions per day
proc_time_dec <- processing_time %>%
  filter(Authorization_Type == "Existing Groundwater Licence", !is.na(`Granted/Offered_Date`)) %>% #  Authorization_Status == "Closed"
  group_by(`Granted/Offered_Date`) %>%
  summarise(decperday = n()) %>% 
  mutate(deccumsum =  cumsum(decperday), Date = `Granted/Offered_Date`)

## Calculate decisions rate to-date starting March 2016
decsum <- sum(proc_time_dec$decperday)
decnumdays <- as.integer(difftime(as.POSIXct(max(proc_time_dec$Date)), as.POSIXct(min(proc_time_dec$Date)), units="days"))
dec_rate <- decsum/decnumdays

## Merge 3 dfs and tidy df
stage_rates <- proc_time_rec %>% 
  left_join(proc_time_acc, by = "Date") %>% 
  left_join(proc_time_dec, by = "Date") %>% 
  select(c(Date, reccumsum, acccumsum, deccumsum)) %>% 
  gather(measure, value, -Date) 

## Individual lines for each transition licence 
ind_proc_time_trans <- processing_time %>%
  filter(Authorization_Type == "Existing Groundwater Licence") %>% 
  rename(Decision_Date = `Granted/Offered_Date`) 

pt_trans_tot <- ind_proc_time_trans %>% 
  group_by(Authorization_Status) %>% 
  summarise(Totals = n())

ind_proc_time_trans <- rownames_to_column(ind_proc_time_trans, "ID")

ind_proc_time_trans <- ind_proc_time_trans %>% 
  mutate(Received = 0, Accepted = difftime(as.POSIXct(ind_proc_time_trans$Accepted_Date),
                                             as.POSIXct(ind_proc_time_trans$Received_Date),
         units="days"),
         Decision = difftime(as.POSIXct(ind_proc_time_trans$Decision_Date),
                             as.POSIXct(ind_proc_time_trans$Received_Date),
                             units="days")) %>% 
  select(ID, nrs_region, Authorization_Status, Received, Accepted, Decision) %>% 
  gather(stage, days, -ID, -nrs_region, -Authorization_Status) 




## Individual lines for each NEW licence 
ind_proc_time_new <- processing_time %>%
  filter(Authorization_Type == "New Groundwater Licence") %>% 
  rename(Decision_Date = `Granted/Offered_Date`) 

pt_new_tot <- ind_proc_time_new %>% 
  group_by(Authorization_Status) %>% 
  summarise(Totals = n())

ind_proc_time_new <- rownames_to_column(ind_proc_time_new, "ID")

ind_proc_time_new <- ind_proc_time_new %>% 
  mutate(Received = 0, Accepted = difftime(as.POSIXct(ind_proc_time_new$Accepted_Date),
                                           as.POSIXct(ind_proc_time_new$Received_Date),
                                           units="days"),
         Decision = difftime(as.POSIXct(ind_proc_time_new$Decision_Date),
                             as.POSIXct(ind_proc_time_new$Received_Date),
                             units="days")) %>% 
  select(ID, nrs_region, Authorization_Status, Received, Accepted, Decision) %>% 
  gather(stage, days, -ID, -nrs_region, -Authorization_Status) 


## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)

save(tot_ta, ta_type, est.df, cat.order, tl_status,
     transition_time_day, rate_forecasts,  app_date, lic_date, proctime_date,
     current_rate, rate_to_achieve, lastday,
     work_day_rate_to_achieve, tl_region,
     tl_purpose, time_region, stage_rates,
     ind_proc_time_trans, ind_proc_time_new,
     pt_new_tot, pt_trans_tot, file = "tmp/trans_gwlic_summaries.RData")
