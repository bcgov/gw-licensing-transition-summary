<div id="devex-badge">
<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>
</div>

# Summarizing and visualizing B.C. ground water licensing transition data 

This repository contains R code for summarizing and visualizing B.C. ground water licensing transition data and generates a summary of the static data visualizations in a PDF document.

## Usage

There are four core scripts that are required for the analysis, they need to be run in order:

- 01_load.R
- 02_clean.R
- 03_analysis.R
- 04_output.R

The `run_all.R` script can be `source`ed to run it all at once.

Most packages used in the analysis can be installed from CRAN using `install.packages()`. You will need to install  [envreportutils](https://github.com/bcgov/envreportutils) using devtools:

```r
install.packages("devtools") # If you don't already have it installed

library(devtools)
install_github("bcgov/envreportutils")
```
 
A Tex/LaTeX software option (e.g. MiKTex or MacTeX) is required to render the `rmarkdown` file to PDF with `knitr`. 

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [Issue](https://github.com/bcgov-c/gw-license-transition-summary/issues).

## How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.


## License

    Copyright 2017 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    
This repository is maintained by the [ENVWater Team](https://github.com/orgs/bcgov/teams/envwater/members) in the [GitHub BCGov Organization](https://github.com/bcgov). 
