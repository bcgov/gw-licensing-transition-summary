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
#library(scales) # percent()
#library(tibble) # rownames_to_column()
library(ggplot2)
library(envreportutils) # theme_soe()
library(stringr) # for label wrapping

## Load clean data if not already in local repository
if (!exists("virtual_clean")) load("tmp/trans_gwlic_clean.RData")


## virtual data summaries

## @knitr pre

## Total licence applications with FCBC
tot_FCBC <- length(virtual_clean$VFCBC_Tracking_Number)


## Total licence applications with FCBC
tot_elic <- length(elic_clean$TrackingNumber)

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
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 3) +
  labs(title = "Transition Applications Currently with FrontCounter BC",
       subtitle = paste("Total Applications = ", tot_FCBC),
       caption = "\nNote: Submitted & Pre-Review includes applications in the pre-submitted,\nsubmitted, pending & editing stages with vFCBC") + 
  scale_fill_manual(values = virtual.colours, name = NULL, breaks = rev(levels(ta_type$Job_Status))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), labels = scales::comma) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "horizontal",
        plot.caption = element_text(size=9)) +
  guides(fill = guide_legend(nrow = 1))

plot(ta_type_plot)


## elic data summaries

## @knitr elic_status

## number of e-licenses by status category with duplicate rows removed
tl_status <- elic_clean %>% 
  group_by(JobStatus) %>% 
  summarise(number = length(JobStatus))

## Change 'Grant' to 'Granted'
tl_status$JobStatus[tl_status$JobStatus == "Grant"] <- "Granted"

## arranging the order of the categories to be plotted
elic.order <- c("Granted", "In Progress", "Parked", "Abandoned")

## reordering the categories for plotting
tl_status$JobStatus <- factor(tl_status$JobStatus, levels = elic.order)

## colour palette
elic.colour <- c("Abandoned" = "#a65628",
           "Parked" = "#4daf4a",
           "In Progress" = "#377eb8",
           "Granted" = "#e41a1c")

## bar chart of incoming E-licence applications by status
tl_status_plot <- ggplot(tl_status, aes(1, y = number, fill = JobStatus)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 3) +
  labs(title = "Transition Applications under Adjudication by E-Licensing:\nCurrent & Completed",
       subtitle = paste("Total Applications = ", tot_elic)) +
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
        plot.title = element_text(size = 12, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

plot(tl_status_plot)

## @knitr elic_regions

## Number applications and predicted number by Region
tl_region <- elic_clean %>%
  mutate(JobStatus = replace(JobStatus, JobStatus=="Grant", "done")) %>%
  mutate(JobStatus = replace(JobStatus, JobStatus=="Abandoned", "done")) %>%
  group_by(nrs_region) %>%
  summarise(Accepted = n() , Decisions = sum(JobStatus == "done")) %>%
  merge(projected_app_clean, by = "nrs_region", all.y=TRUE) %>%
  gather(type, value, -nrs_region) %>%
  mutate(value = ifelse(is.na(value), 0, value))

## arranging the order of the categories to be plotted
elic.region.order <- c("Projected", "Accepted", "Decisions")

## reordering the categories for plotting
tl_region$type <- factor(tl_region$type, levels = elic.region.order)

## order df for plotting
tl_region<- order_df(tl_region, target_col = "nrs_region", value_col = "value", fun = max, desc = TRUE)

## colour paletts
elic.region.colours <- c("Projected" = "#999999",
           "Accepted" = "#377eb8",
           "Decisions" = "#e41a1c")


app_regions_plot <- ggplot(data = tl_region, aes(x = nrs_region, y = value, fill = type)) +
  geom_bar(stat="identity", position = "dodge", alpha = 0.7) +
  geom_text(aes(label = value), position = position_dodge(.9),  vjust = -.5, size = 3) +
  labs(title = "Status of Accepted Transitioning Groundwater Licences\n by NRS Region",
       caption = "\nNote: Decisions include Granted and Abandoned applications") +
  scale_fill_manual(values = elic.region.colours, name=NULL) +
  xlab(NULL) +
  ylab("Number of Applications") +
  theme_soe() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, 5400), breaks = seq(0, 5400, 1000), labels = scales::comma) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 8)) +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = c(.75,.76),
        legend.background = element_rect(fill = "transparent"),
        plot.caption = element_text(size=9))

plot(app_regions_plot)

## @knitr water_use

## number of elic licenses by purpose use category, includes duplicate IDs
tl_purpose <- elic_clean_dup %>% 
  filter(JobStatus != "Abandoned") %>% 
  group_by(PurposeUse) %>% 
  summarise(number = length(PurposeUse)) %>% 
  mutate(perc_tot = paste0(round((number/sum(number)*100), digits = 0),"%"))

tl_purpose <- order_df(tl_purpose, target_col = "PurposeUse", value_col = "number", fun = max, desc = TRUE)

## bar chart of Water Use Purposes for incoming E-licence applications
tl_use_plot <- ggplot(tl_purpose, aes(x = PurposeUse, y = number)) +
  geom_col(alpha = 0.7, fill = "#377eb8") +
  geom_text(aes(label = perc_tot), vjust = .2, hjust = -.2, size = 3) +
  labs(title = "Transitioning Groundwater Licences \nby Granted/Approved - Water Use Purposes",
       caption = "\nNote: Some licences have more than one water use purpose") +
  xlab(NULL) +
  ylab("Number of Incoming Licences") +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, max(tl_purpose$number) + max(tl_purpose$number/10))) +
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_text(size=10),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        plot.title = element_text(size = 12, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=9),
        plot.caption = element_text(size=9))

plot(tl_use_plot)


## Plots that use data from BOTH virtual & elic dataframes

## @knitr estimate

## make a 'total transition applications with estimated transitions' dataframe
est_ta <- 20000
tot_ta <- tot_FCBC + tot_elic

remaining <- est_ta-tot_ta
cat <- c("Estimated Outstanding", "Number Recieved To-Date")
val <- c(remaining, tot_ta)
est.df <- data.frame(cat, val)

est.df<- order_df(est.df, target_col = "cat", value_col = "val", fun = max, desc = TRUE)

two_colrs <- c("Number Recieved To-Date" = "#3182bd",
               "Estimated Outstanding" = "grey70")

## bar chart of total received and estimated applications
tot_est_plot <- ggplot(est.df, aes(1, y = val, fill = cat)) +
  geom_col(alpha = .7) +
  geom_text(aes(label = val), position = position_stack(vjust = 0.5), size = 3) +
  labs(title = "All Transition Applications Received To-Date Compared\nto Expected Number") +
  scale_fill_manual(values = two_colrs, name = NULL, breaks = rev(levels(est.df$cat))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), limits = c(0,21000), breaks=seq(0, 20000, 5000), labels = scales::comma) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "horizontal")

plot(tot_est_plot)

## @knitr end


# ## @knitr app_rate
# 
# ## Calculate, plot and forecast rate/s of incoming transition applications
# 
# ## calculate the num applications per day
# app_per_day <- virtual_clean %>%
#   group_by(Date_Submitted) %>%
#   summarise(numperday = n())
# 
# ## mean number per day over period
# mean_rate_per_day <- mean(app_per_day$numperday)
# 
# ## What days are people applying
# # app_per_day$day <- wday(as.Date(app_per_day$Date_Submited), label=TRUE, abbr = FALSE)
# # day_plot <- ggplot(app_per_day, aes(day, numperday)) +
# #   geom_col(alpha = 0.7)
# # plot(day_plot)
# 
# ## cumlative sum of applications and add to df
# app_per_day$cumsum <- cumsum(app_per_day$numperday)
# 
# ## Calculate current rate to-date
# appsum <- sum(app_per_day$numperday)
# firstday <- min(app_per_day$Date_Submitted)
# lastday <- max(app_per_day$Date_Submitted)
# numdays <- as.integer(difftime(as.POSIXct(lastday), as.POSIXct(firstday), units = "days"))
# current_rate <- appsum/numdays
# 
# ## Calculate rate forecast based on current rate and add to df
# enddate <- as.Date(as.character("2019-03-01"))
# date <- seq(lastday, enddate, by = "1 day")
# rate_forecasts <- data.frame(date)
# rate_forecasts$curr_num <- current_rate
# rate_forecasts$curr_num[1] <- appsum
# rate_forecasts$curr_cumsum <- cumsum(rate_forecasts$curr_num)
# 
# ## Calculate the required rate for March 2019 end date and add to df
# app_to_go <- est_ta - appsum
# days_to_go <- as.integer(enddate - lastday)
# rate_to_achieve <- app_to_go/days_to_go
# rate_forecasts$req_num <- rate_to_achieve
# rate_forecasts$req_num[1] <- appsum
# rate_forecasts$req_cumsum <- cumsum(rate_forecasts$req_num)
# 
# ## Calculate the required rate for March 2019 end date for workdays only
# work_days_to_go <- sum(!weekdays(seq(lastday, enddate, "days")) %in% c("Saturday", "Sunday"))
# work_day_rate_to_achieve <- app_to_go/work_days_to_go
# 
# 
# ## line chart of incoming transition license applications to VFCBC by date and rates
# tl_rate_plot <- ggplot() +
#   geom_point(data = app_per_day, aes(y = cumsum, x = Date_Submitted),
#              alpha = 0.7, colour = "#08519c", size = 1) +
#   labs(title = "Observed Submission Rate of Transition\nApplications Compared to Target Rate") +
#   geom_line(data = rate_forecasts, aes(y = curr_cumsum, x = date), alpha = 0.7,
#             colour = "#08519c", size = 1, linetype = 2) +
#   geom_line(data = rate_forecasts, aes(y = req_cumsum, x = date), alpha = 0.7,
#             colour = "#006d2c", size = 1, linetype = 2) +
#   annotate("text", label = paste("Average Rate of Application\nSubmissions To Date:\n", round(current_rate, digits = 1), "/day", sep = ""), colour = "#08519c",
#            x = as.Date(as.character("2016-11-01")), y = 4000, size = 4) +
#   annotate("text", label = paste("Target Rate of Application\nSubmissions Starting ", ddate,":\n",
#                                  round(rate_to_achieve, digits = 0), "/day", " (or ", round(work_day_rate_to_achieve, digits = 0),"/weekday)",  sep = ""), colour = "#006d2c",
#            x = as.Date(as.character("2017-11-01")), y = 16000, size = 4) +
#   scale_y_continuous(expand=c(0, 0), limits = c(0,20000), breaks=seq(0, 20000, 2000), labels = scales::comma) +
#   xlab(NULL) +
#   ylab("Number of Applications") +
#   theme_soe() +
#   theme(panel.grid.major.x = element_blank(),
#         axis.text = element_text(size=10),
#         plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
#         plot.margin = unit(c(5,5,5,5),"mm"))
# plot(tl_rate_plot)


