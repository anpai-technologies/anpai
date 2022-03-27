# Anpai Meetings
## Installation
```
library(devtols)
devtools::install_github("anpai-technologies/anpai")
```
## Usage
#### Read an ICS-file
```
library(anpai)
anpai::read_ics(<path_to_ics>)
```
#### Change timezone of meetings
```
library(anpai)
library(dplyr)
meetings <- anpai::read_ics(<path_to_ics>) %>%
				anpai::change_tz("America/Los_Angeles") 
```

#### Compute meeting summary statistics
```
library(anpai)
library(dplyr)
meetings <- anpai::read_ics(<path_to_ics>) %>%
				anpai::describe_cal() 
```