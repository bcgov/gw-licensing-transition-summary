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


library(officer)

read_pptx() %>% 
  add_slide(layout = "Title Slide", master = "Office Theme") %>% 
  ph_with_text(type = "ctrTitle", str = "Status of Transitioning Groundwater User Water Licence Applications") %>%
  ph_with_text(type = "subTitle", str = paste0("Data provided by FLNRO Water Management Branch on ", ddate)) %>%
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = tl_rate_plot, width = 9, height = 5.5, left = 0.5, top = 1) %>% 
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = tot_est_plot, width = 9, height = 3.8, left = 0.5, top = 2) %>% 
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = ta_type_plot, width = 9, height = 3.8, left = 0.5, top = 2) %>% 
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = tl_status_plot, width = 9, height = 3.8, left = 0.5, top = 2) %>% 
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = app_regions_plot, width = 9, height = 7, left = 0.5, top = 0.1) %>% 
  add_slide(layout = "Title and Content", master = "Office Theme") %>% 
  ph_with_gg_at(value = tl_use_plot, width = 9, height = 7, left = 0.5, top = 0.1) %>% 
  print(target = paste0("ENV_GW_Licensing_Transition_Summary_asof_", ddate, ".pptx"))
