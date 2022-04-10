<h1 align="center">
	<img width="200" src="https://anpaimeetingslogo.s3.us-east-2.amazonaws.com/anpai_logo.png" alt="Anpai Technologies">
	<br>

</h1>
<div align="center">
	<a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed."></a>
  <a href="https://github.com/GuangchuangYu/badger/actions" target="_blank"><img src="https://github.com/GuangchuangYu/badger/workflows/R-CMD-check/badge.svg" alt="R build
status"></a>
   <a href="https://join.slack.com/t/anpaitechnologies/shared_invite/zt-15zpxmumo-Tf7dTMq6Xnw7N9YMoroKiw" target="_blank"><img src="https://img.shields.io/badge/slack-@anpaitechnologies-brightgreen.svg?logo=slack" alt="Slack invite"></a>

  <h3 align="center">
    <a href="https://www.anp.ai?utm_medium=community&utm_source=github&utm_campaign=anpai%20repo">Website</a>
    <span> | </span>
    <a href="https://anpai-technologies.github.io/anpai/">Docs</a>
    <span> | </span>
    <a href="https://join.slack.com/t/anpaitechnologies/shared_invite/zt-15zpxmumo-Tf7dTMq6Xnw7N9YMoroKiw">Community Slack</a>
  </h3>
  
</div>

-----------------------

[Anpai](https://anp.ai?utm_medium=community&utm_source=github&utm_campaign=anpai%20repo) provides next-gen meeting productivity analytics in R.
* Read ICS-files into ready-to-go tibbles.
* Visualize and analyze your meeting data.
* Improve your productivity by better understanding schedules.

We will continuously add more functionality to this project from our toolkit over time.

If you like this project, we would really appreciate **a star ⭐!**

----------------------------------

## ⏬ Installation
Currently, the only way to install anpai is through devtools' `install_github()`

``` r
## install.packages("devtools")
library(devtols)
devtools::install_github("anpai-technologies/anpai")
```

----------------------------

## 📖 Example Workflows

#### Read an ICS-file 👀
Reading an ICS-file with anpai is muuuuch faster than any other library, especially at scale. That's all thanks to `Rcpp` providing the necessary firepower.

``` r
library(anpai)

anpai::read_ics(<path_to_ics>)
```

#### Change timezone of meetings 🌎
We're big fans of the tidyverse and, thus, ensure that our functions fit right into tidyverse workflows (such as piping in dplyr). Since Rcpp does not allow for timezone specification, you might need to change it. 

``` r
library(anpai)
library(dplyr)

meetings <- anpai::read_ics(<path_to_ics>) %>%
				      anpai::change_tz("America/Los_Angeles") 
```

#### Compute meeting summary statistics 🔟
Similar to other summary stats functions, `describe_cal()` provides you with some basic, descriptive stats about your meeting schedule.

``` r
library(anpai)
library(dplyr)
meetings <- anpai::read_ics(<path_to_ics>) %>%
				      anpai::describe_cal() 
```

Here's an exemplary output:

``` 
# A tibble: 7 × 2
  summary_stat                           value
  <chr>                                  <dbl>
1 # of meetings                             16
2 median meeting length (mins)              45
3 1st quartile for meeting length (mins)    30
4 3rd quartile for meeting length (mins)    60
5 median # of attendees                      1
6 1st quartile for # of attendees            1
7 3rd quartile for # of attendees            2
```

#### Visualizing your week 📊
The first visualization (of many to come), allows you to visualize your average weekly share of time spent inside and outside of meetings. It's all `ggplot2`, so customize all you want!

``` r
library(anpai)
library(dplyr)

anpai::read_ics(<path_to_ics>) %>%
	anpai::dow_plot() 
```

The above will yield the following plot:

<img height="300" width="450" src="https://anpaimeetingslogo.s3.us-east-2.amazonaws.com/timeshare.png" alt="Anpai Technologies">

#### Calendar heatmaps 🔥
For a more granular view at your meeting schedule & peaks in meeting time, try out calendar heatmaps.

``` r
library(anpai)
library(dplyr)

anpai::read_ics(<path_to_ics>) %>%
	anpai::cal_heatmap() 
```

The above will yield the following plot:

<img height="600" width="355" src="https://anpaimeetingslogo.s3.us-east-2.amazonaws.com/cal_heatmap.png" alt="Anpai Technologies">

#### Want to know what you'll get done between meetings next week? ✅
Planning the time between meetings is just as important as planning the meetings themselves. Find out what you'll get done next week.

``` r
library(anpai)
library(dplyr)

anpai::read_ics(<path_to_ics>) %>%
	anpai::plot_breaks() 
```

Aaand here's the resulting plot:

<img height="300" width="450" src="https://anpaimeetingslogo.s3.us-east-2.amazonaws.com/brea_time.png" alt="Anpai Technologies">


----------------------

## 🔨 Contributing

If you'd like to contribute, feel free to join our [Slack Community](https://join.slack.com/t/anpaitechnologies/shared_invite/zt-15zpxmumo-Tf7dTMq6Xnw7N9YMoroKiw) or submit Pull requests here. Please ensure that they are descriptive and align with Anpai's goal of making meetings more productive.

----------------------

## 📖 Licensing
This code is distributed under the GPL v3 license.
