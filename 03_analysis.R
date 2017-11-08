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
vir.order <- c("Under Review", "Submitted & Pre-Review Steps", "Cancelled & Not Accepted")

## reordering the categories for plotting
ta_type$Job_Status <- factor(ta_type$Job_Status, levels = vir.order)

## set colour palette
virtual.colours <- c("Accepted" = "#e41a1c",
             "Under Review" = "#377eb8",
             "Submitted & Pre-Review Steps" = "#4daf4a",
             "Cancelled & Not Accepted" = "#a65628")

## bar chart of CURRENT applications into VFCBC by status description (does not include accepted applications)
ta_type_plot <- ggplot(ta_type, aes(1, y = n, fill = Job_Status)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FrontCounter BC Transition\nApplication Intake Process") +
  scale_fill_manual(values = virtual.colours, name = NULL, breaks = rev(levels(ta_type$Job_Status))) +
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

## @knitr elic_status

## number of e-licenses by status category with duplicate rows removed
tl_status <- elic_clean %>% 
  group_by(JobStatus) %>% 
  summarise(number = length(JobStatus))

## Change 'Grant' to 'Granted'
tl_status$JobStatus[tl_status$JobStatus == "Grant"] <- "Decision"

## arranging the order of the categories to be plotted
elic.order <- c("Decision", "In Progress", "Parked", "Abandoned")

## reordering the categories for plotting
tl_status$JobStatus <- factor(tl_status$JobStatus, levels = elic.order)

## colour palette
elic.colour <- c("Abandoned" = "#a65628",
           "Parked" = "#4daf4a",
           "In Progress" = "#377eb8",
           "Decision" = "#e41a1c")

## bar chart of incoming E-licence applications by status
tl_status_plot <- ggplot(tl_status, aes(1, y = number, fill = JobStatus)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FLNRO Adjudication: Transition Applications") +
  scale_fill_manual(values = elic.colour, name = NULL,
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

## @knitr elic_regions

## Number applications and predicted number by Region
tl_region <- elic_clean %>%
  group_by(nrs_region) %>%
  summarise(accepted = n() , decision = sum(JobStatus == "Grant")) %>%
  merge(projected_app_clean, by = "nrs_region", all.y=TRUE) %>%
  gather(type, value, -nrs_region) %>%
  mutate(value = ifelse(is.na(value), 0, value))

## arranging the order of the categories to be plotted
elic.region.order <- c("projected", "accepted", "decision")

## reordering the categories for plotting
tl_region$type <- factor(tl_region$type, levels = elic.region.order)

## order df for plotting
tl_region<- order_df(tl_region, target_col = "nrs_region", value_col = "value", fun = max, desc = TRUE)

## colour paletts
elic.region.colours <- c("projected" = "#999999",
           "accepted" = "#377eb8",
           "decision" = "#e41a1c")

new_lab <- c("projected" = "Projected",
             "decision" = "Decision",
             "accepted" = "Accepted")

app_regions_plot <- ggplot(data = tl_region, aes(x = nrs_region, y = value, fill = type)) +
  geom_bar(stat="identity", position = "dodge", alpha = 0.7) +
  geom_text(aes(label = value), position = position_dodge(.9),  vjust = -.5, size = 2) +
  labs(title = "Accepted & Granted Transition Applications Compared with\nProjected Numbers By NRS Region") +
  scale_fill_manual(values = elic.region.colours, name=NULL,
                    labels=new_lab) +
  xlab(NULL) +
  ylab("Number of Applications") +
  theme_soe() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, 5200), breaks = seq(0, 5200, 1000), labels = scales::comma) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 8)) +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = c(.75,.76),
        legend.background = element_rect(fill = "transparent"))

plot(app_regions_plot)

## @knitr water_use

## number of elic licenses by purpose use category, includes duplicate IDs
tl_purpose <- elic_clean_dup %>% 
  group_by(PurposeUse) %>% 
  summarise(number = length(PurposeUse)) %>% 
  mutate(perc_tot = paste0(round((number/sum(number)*100), digits = 0),"%"))

tl_purpose <- order_df(tl_purpose, target_col = "PurposeUse", value_col = "number", fun = max, desc = TRUE)

## bar chart of Water Use Purposes for incoming E-licence applications
tl_use_plot <- ggplot(tl_purpose, aes(x = PurposeUse, y = number)) +
  geom_col(alpha = 0.7, fill = "#377eb8") +
  geom_text(aes(label = perc_tot), vjust = .2, hjust = -.2, size = 3) +
  labs(title = "Incoming Transition Licences by Water Use Purpose",
       caption = "\n**Note: Some licences have more than one water use purpose") +
  xlab(NULL) +
  ylab("Number of Incoming Licences") +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, max(tl_purpose$number) + max(tl_purpose$number/10))) +
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_text(size=10),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 1.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=9))

plot(tl_use_plot)


## Plots that use data from BOTH virtual & elic dataframes

## @knitr estimate

## make a 'total transition applications with estimated transitions' dataframe
est_ta <- 20000

## add up licences in virtual and licences in elic for total applications to-date
tot_ta <- length(virtual_clean$VCFBC_Tracking_Number) + length(elic_clean$TrackingNumber)

remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding Transition Applications", "Current Number Transition Applications")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)

two_colrs <- c("Current Number Transition Applications" = "#3182bd",
               "Estimated Outstanding Transition Applications" = "grey70")

## bar chart of total received and estimated applications
tot_est_plot <- ggplot(est.df, aes(1, y = val, fill = cat)) +
  geom_col(alpha = .7) +
  geom_text(aes(label = val), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Received Transition Applications Compared to Expected") +
  scale_fill_manual(values = two_colrs, name = NULL, breaks = rev(levels(est.df$cat))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), limits = c(0,21000), breaks=seq(0, 20000, 5000), labels = scales::comma) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "horizontal")

plot(tot_est_plot)



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







## Create tmp folder if not already there and store clean data in local repository
if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)

save(tot_ta, ta_type, est.df, cat.order, tl_status,
     transition_time_day, rate_forecasts,  app_date, lic_date, proctime_date,
     current_rate, rate_to_achieve, lastday,
     work_day_rate_to_achieve, tl_region,
     tl_purpose, time_region, stage_rates,
     ind_proc_time_trans, ind_proc_time_new,
     pt_new_tot, pt_trans_tot, file = "tmp/trans_gwlic_summaries.RData")
