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

library(ggplot2) 
library(envreportutils) # theme_soe()
library(RColorBrewer) #for colour palette


## Load clean data if not already in local repository
if (!exists("ta_type")) load("tmp/trans_gwlic_summaries.RData")

## @knitr pre

## PLOTS

## @knitr estimate

## bar chart of total and estimated applications
tot_est_plot <- ggplot(est.df, aes(1, y = val, fill = cat)) +
  geom_col(alpha = .7) +
  geom_text(aes(label = val), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Applications Received by FrontCounter BC") +
  scale_fill_manual(values = c("grey70", "#3182bd"), name = NULL, breaks = rev(levels(est.df$cat))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0.005, 0)) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=6),
        plot.title = element_text(size = 8),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=6),
        legend.position = "bottom",
        legend.direction = "horizontal")

plot(tot_est_plot)


## @knitr types

## bar chart of all applications by status description

## get number of categories and set colour palette
type.no <- length(cat.order)+1
colr.pal <- brewer.pal(type.no, "Set1")


ta_type_plot <- ggplot(ta_type, aes(1, y = number, fill = StatusDescription)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "FrontCounter BC Process Status") +
  scale_fill_manual(values = colr.pal, name = NULL, breaks = rev(levels(ta_type$StatusDescription))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0.005, 0)) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=6),
        plot.title = element_text(size = 8),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=6),
        legend.position = "bottom",
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

plot(ta_type_plot)


## @knitr in_progress

## bar chart of incoming licenses by status
tl_status_plot <- ggplot(tl_status, aes(1, y = number, fill = JobStatus)) +
  geom_col(alpha = 0.7) +
  geom_text(aes(label = number), position = position_stack(vjust = 0.5), size = 2) +
  labs(title = "Applications Granted & Under Adjudication by FLNRO") +
       # subtitle = paste("Parked:", tl_parked, " ", "Abandoned:", tl_abandon)) +
  scale_fill_manual(values = c("#6baed6", "#3182bd", "grey80", "#b15928"), name = NULL,
                    breaks = rev(levels(tl_status$JobStatus))) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  coord_flip() +
  scale_y_continuous(expand=c(0.005, 0)) +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size=6),
        plot.title = element_text(size = 8),
        plot.margin = unit(c(5,5,5,5),"mm"),
        legend.text = element_text(size=6),
        legend.position = "bottom",
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

plot(tl_status_plot)


## @knitr app_rate

## line chart of incoming transition licenses by date and rates
tl_rate_plot <- ggplot(transition_time_day, aes(y = cumsum, x = `Received Date`)) +
  geom_line(alpha = 0.7, colour = "#3182bd", size = 1) +
  labs(title = "Transition Application Submission Date") +
  geom_text(data = wrkshops, aes(x = date, y = cumsum, label = label)) +
  xlab(NULL) +
  ylab(NULL) +
  theme_soe() +
  theme(panel.grid.major.x = element_blank(),
        axis.text = element_text(size=6),
        plot.title = element_text(size = 8),
        plot.margin = unit(c(5,5,5,5),"mm"))

plot(tl_rate_plot)



## @knitr end

