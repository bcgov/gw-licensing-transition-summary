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

library(ggplot2) #plotting
library(dplyr) # data munging
library(envreportutils) # theme_soe()
library(stringr) # for label wrapping
library(RColorBrewer) #for colour palette


## Load clean data if not already in local repository
if (!exists("ta_type")) load("tmp/trans_gwlic_summaries.RData")


## @knitr pre

## PLOTS


##### RECEIVED APPLICATIONS ######

## @knitr estimate

## bar chart of total and estimated applications

two_colrs <- c("Current Number" = "#3182bd",
               "Estimated Outstanding" = "grey70")

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

## @knitr app_rate

## line chart of incoming transition licenses by date and rates
tl_rate_plot <- ggplot() +
  geom_line(data = transition_time_day, aes(y = cumsum, x = ApplicationDate),
            alpha = 0.7, colour = "#08519c", size = 1) +
  labs(title = "Observed Submission Rate of Transition\nApplications Compared to Target Rate") +
  geom_line(data = rate_forecasts, aes(y = curr_cumsum, x = date), alpha = 0.7,
            colour = "#08519c", size = 1, linetype = 2) +
  geom_line(data = rate_forecasts, aes(y = req_cumsum, x = date), alpha = 0.7,
            colour = "#006d2c", size = 1, linetype = 2) +
  annotate("text", label = paste("Average Rate of Application\nSubmissions To Date:\n", round(current_rate, digits = 1), "/day", sep = ""), colour = "#08519c",
           x = as.POSIXct(as.character("2016-11-01")), y = 4000, size = 4) +
  annotate("text", label = paste("Target Rate of Application\nSubmissions Starting ", app_date,":\n",
                                 round(rate_to_achieve, digits = 0), "/day", " (or ", round(work_day_rate_to_achieve, digits = 0),"/weekday)",  sep = ""), colour = "#006d2c",
           x = as.POSIXct(as.character("2017-11-01")), y = 16000, size = 4) +
  scale_y_continuous(expand=c(0, 0), limits = c(0,20000), breaks=seq(0, 20000, 2000), labels = scales::comma) +
  xlab(NULL) +
  ylab("Number of Applications") +
  theme_soe() +
  theme(panel.grid.major.x = element_blank(),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"))

plot(tl_rate_plot)


##### ACCEPTED APPLICATIONS ######

## @knitr types

## bar chart of all applications by status description

## get number of categories and set colour palette
type.no <- length(cat.order)+1
colr.pal <- brewer.pal(type.no, "Set1")

ta_type_plot <- ggplot(ta_type, aes(1, y = n, fill = StatusDescription)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FrontCounter BC Transition\nUser Application Intake Process") +
  scale_fill_manual(values = colr.pal, name = NULL, breaks = rev(levels(ta_type$StatusDescription))) +
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

## @knitr app_regions

colrs <- c("projected" = "#999999",
           "received" = "#377eb8",
           "accepted" = "#e41a1c")

new_lab <- c("projected" = "Projected",
             "received" = "Received",
             "accepted" = "Accepted")

app_regions_plot <- ggplot(data = ta_region, aes(x = nrs_region, y = value, fill = type)) +
  geom_bar(stat="identity", position = "dodge", alpha = 0.7) +
  geom_text(aes(label = value), position = position_dodge(.9),  vjust = -.5, size = 2) +
  labs(title = "Received & Accepted Transition Applications Compared with\nProjected Numbers By NRS Region") +
  scale_fill_manual(values = colrs, name=NULL,
                    labels=new_lab) +
  xlab(NULL) +
  ylab("Number of Applications") +
  theme_soe() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, 6000), breaks = seq(0, 6000, 1000), labels = scales::comma) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 8)) +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = c(.75,.75),
        legend.background = element_rect(fill = "transparent"))

plot(app_regions_plot)


##### ADJUDICATION AND DECISION OF APPLICATIONS ######

## @knitr incoming

## bar chart of incoming licenses by status

colr2 <- c("Abandoned" = "#a65628",
          "Parked" = "#4daf4a",
          "In Progress" = "#377eb8",
          "Granted" = "#e41a1c")

tl_status_plot <- ggplot(tl_status, aes(1, y = number, fill = JobStatus)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FLNRO Adjudication: Transition User Applications") +
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


## @knitr water_use
## bar chart of Water Use Purposes for incoming licenses

tl_use_plot <- ggplot(tl_purpose, aes(x = PurposeUse, y = number)) +
  geom_col(alpha = 0.7, fill = "#377eb8") +
  geom_text(aes(label = perc_tot), vjust = .2, hjust = -.2, size = 3) +
  labs(title = "Number & Percent of Incoming Transition Licences by Water Use Purposes") +
  xlab(NULL) +
  ylab("Number of Incoming Licences") +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, max(tl_purpose$number) + max(tl_purpose$number/10))) +
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_text(size=10),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 1.1, face = "bold"),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=9))

plot(tl_use_plot)




## @knitr end

