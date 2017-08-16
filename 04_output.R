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
  geom_point(data = transition_time_day, aes(y = cumsum, x = ApplicationDate),
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

## set colour palette
colours <- c("Accepted" = "#e41a1c",
           "Under Review" = "#377eb8",
           "Submitted & Pre-Review Steps" = "#4daf4a",
           "Cancelled & Not Accepted" = "#a65628")

ta_type_plot <- ggplot(ta_type, aes(1, y = n, fill = StatusDescription)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Status of FrontCounter BC Transition\nApplication Intake Process") +
  scale_fill_manual(values = colours, name = NULL, breaks = rev(levels(ta_type$StatusDescription))) +
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
        legend.position = c(.75,.76),
        legend.background = element_rect(fill = "transparent"))

plot(app_regions_plot)


##### ADJUDICATION AND DECISION OF APPLICATIONS ######

## @knitr incoming

## bar chart of incoming licence applications by status

colr2 <- c("Abandoned" = "#a65628",
          "Parked" = "#4daf4a",
          "In Progress" = "#377eb8",
          "Granted" = "#e41a1c")

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


## @knitr water_use
## bar chart of Water Use Purposes for incoming licence applications

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


##### PROCESSING TIME ######

## @knitr proc_time

proc_time_data <- filter(time_region, measure == "diff_time" | measure == "avg_net_time")
proc_time_labels <-  filter(time_region, measure == "avg_tot_time")

## arranging the order of the categories to be plotted
time.order <-  c("diff_time", "avg_net_time")

## ordering the categories for plotting
proc_time_data$measure <- factor(proc_time_data$measure, levels = time.order)

lic_colrs <- c("avg_net_time" = "#3182bd",
               "diff_time" = "grey70")

time_lab <- c("avg_net_time" = "Average Net Processing Time (excludes days on hold)",
              "diff_time" = "Time On Hold")


proc_time_plot <- ggplot(data = proc_time_data) +
  geom_col(aes(x = Authorization_Type, y = value, fill = measure), alpha = 0.7) +
  geom_text(data = proc_time_labels, aes(x = Authorization_Type, y = value, label = num_dec),
            vjust = -.4, size = 3, show.legend = FALSE) +
  facet_wrap(~ nrs_region, ncol = 2) +
  labs(title = "Number of Decisions & Average Processing Time\nby NRS Region Since March 2016",
       caption = "Bars Labelled with Number of Decisions") +
  scale_fill_manual(values = lic_colrs, name=NULL,
                    labels=time_lab, drop = TRUE) +
  xlab(NULL) +
  ylab("Time in Days") +
  theme_soe_facet() +
  scale_y_continuous(expand=c(0, 0), limits = c(0, max(proc_time_labels$value) + max(proc_time_labels$value/5))) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 8)) +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.caption = element_text(size = 10, hjust = 0.3),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=10),
        legend.position = "bottom",
        legend.direction = "vertical")

plot(proc_time_plot)

## @knitr stage_rates

## line chart of rates 3 stages of licensing 

rate_colrs <- c("reccumsum" = "#999999",
           "acccumsum" = "#377eb8",
           "deccumsum" = "#e41a1c")

rate_lab <- c("reccumsum" = "Received",
              "acccumsum" = "Accepted",
              "deccumsum" = "Decisions")

## arranging the order of the categories to be plotted
rate.order <-  c("reccumsum", "acccumsum", "deccumsum")

## ordering the categories for plotting
stage_rates$measure <- factor(stage_rates$measure, levels = rate.order)


stage_rate_plot <- ggplot(stage_rates, aes(x = Date, y = value, colour = measure)) +
  geom_point(size = 3) +
#  geom_smooth(method = "loess") +
  labs(title = "Number of Transition Licences by Processing Stage") +
#       subtitle = paste("Data sourced from FLNRO FCBC 'ATS system application processing time report' and accessed on", proctime_date)) +
  scale_y_continuous(expand=c(0, 0), limits = c(0, 1200), breaks=seq(0, 1200, 200), labels = scales::comma) +
  scale_colour_manual(values = rate_colrs, name=NULL,
                    labels=rate_lab) +
  xlab(NULL) +
  ylab("Cumulative Number") +
  theme_soe() +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12,face = "bold", hjust = 0.5), # hjust = 0.5,
   #     plot.subtitle = element_text(size = 8),
        legend.text = element_text(size=12),
        legend.position = c(.25,.58),
        legend.background = element_rect(fill = "transparent"),
        plot.margin = unit(c(5,5,5,5),"mm"))

plot(stage_rate_plot)

## @knitr end stage_rates

## Save PNG of plot
png(filename = "./tmp/gw_translic_proc_rates.png", width = 836, height = 489, units = "px", type = "cairo-png")
plot(stage_rate_plot)
dev.off()

## @knitr line_facet

## line plot for individual transitiotn lic applications timelines
## arranging the order of the categories to be plotted
stage.order <-  c("Received", "Accepted", "Decision")

## ordering the categories for plotting
ind_proc_time$stage <- factor(ind_proc_time$stage, levels = stage.order)

## colours for categories
line_colrs <- c("Active" = "#377eb8",
                "Closed" = "#e41a1c",
                "On Hold" = "#4daf4a")

line_labs <- c("Active" = "In Progress",
               "Closed" = "Completed",
               "On Hold" = "On Hold")

ind_ta_plot <- ggplot(ind_proc_time, aes(x = days, y = stage, group = ID, colour = Authorization_Status)) +
  geom_line(size = .75) +
  geom_vline(xintercept = 140, linetype = 2, colour = "grey40") +
  annotate("text", label ="140 days", colour = "grey40",
           x = 190, y = .7, size = 3.5) +
  geom_vline(xintercept = 280, linetype = 2, colour = "grey40") +
  annotate("text", label ="280 days", colour = "grey40",
           x = 335, y = .7, size = 3.5) +
  facet_wrap(~ nrs_region, ncol = 2) +
  labs(title = "Status & Processing Time of Individual Groundwater\nTransition Licence Applications by NRS Region",
       subtitle = "Each line is an individual application, where recieved = day zero",
       caption = "\nNote: No applications have been submitted to-date in the Kootenay Boundary NRS Region\nand number of days includes days on hold") +
   scale_colour_manual(values = line_colrs, labels=line_labs, name= NULL) +
#   scale_y_continuous(expand=c(0, 0)) +
  ylab(NULL) +
  xlab("Number of Days") +
  theme_soe_facet() +
  theme(panel.grid.major.x = element_blank(),
        axis.title.y = element_text(size=10),
        axis.text = element_text(size=10),
        plot.title = element_text(size = 12, hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(size = 10,  hjust = 0.5),
        plot.caption = element_text(size = 9, hjust = 0.5),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=12),
        legend.position = "top",
        legend.direction = "horizontal")

plot(ind_ta_plot)

## @knitr end

## Save PNG of plot
png(filename = "./tmp/indiviual_gw_translic_status_byregion.png", width = 836, height = 689, units = "px", type = "cairo-png")
plot(ind_ta_plot)
dev.off()



