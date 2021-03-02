# UVX Headway Adherence

This project contains analysis code related to the study of headway adherence on
UVX. The project is built as an RMarkdown website.

The Utah Valley Express (UVX) is a bus rapid transit line in Provo and Orem, Utah.
The system runs with six or ten-minute headways during most weekdays. Though UVX 
does not publish a schedule with regular timepoints as most UTA services do, 
there is still a service schedule for integration with wayfinding software and for
UTA's internal tracking. 

The vehicles and  traffic signals on the route are equipped with Transit Signal
Priority (TSP) transponders. The system works such that if the buses are running
behind their schedule, the bus can request additional green time from the traffic
signals. There are four settings for this TSP system:

  - `OFF`: The TSP does not make any requests of the traffic signal. The system
    still informs the signal to run the bus cycle when a bus is present.
  - `5`: The TSP requests additional green time if it is running five minutes or
  more behind its schedule.
  - `2`: The TSP requests additional green time if it is running two minutes or
  more behind its schedule.
  - `ON`: The TSP always requests additional green time.
  

In this project, we use automated vehicle location (AVL) data provided by UTA
for the UVX project to determine the effect different TSP threshold settings have
on headway adherence. A related research project funded by UDOT is examining the
effect of these different thresholds on schedule adherence. UTA mostly cares 
about the latter, but it is possible that an effect can be more clearly seen in 
headways and in a bus-bunching scenario.

## Building this document
The document is built using bookdown for R, with code embedded in the document
text. To install the packages used in this analysis, run

```r
install.packages(c("tidyverse", "lubridate"))
```

The data for this study is stored in a collection of zipped CSV files in 
the `data/UVX_Reliability_2019.csv.zip` file. An R script at `R/datamaker.R`
constructs an rds file called `data/uvx_timepoints.rds` which is the starting
point for this analysis; that is, you will need to run the `R/datamaker.R` script
before you attempt to build the document.

