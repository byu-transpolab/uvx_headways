library(tidyverse)
library(lubridate)

# Download file from Box if not present (also committed to repo)
raw_file <- "data/UVX_Reliability_2019.csv.zip"
if(!file.exists(raw_file)){
  download.file("https://byu.box.com/shared/static/nkf9nh63oqp501ech59urzzi738sio5l.zip", raw_file)
}

raw_data <- read_csv(
  raw_file, 
  # read everything in as a character string
  col_types = str_c(rep("c", 24), collapse = "") )


processed_data <- raw_data %>%
  transmute(
    # Route and direction IDs
    route = Route, direction = substr(Direction, 0, 2), 
    trip = Trip,
    timepoint = `Time Point`,
    vehicle = Vehicle,
    
    # Time points
    date = as_date(mdy(NEW_Date)),
    time = as_datetime(str_c(mdy(NEW_Date), " ", DepartureTime)),
    schedule = as_datetime(str_c(mdy(NEW_Date), " ", Schedule, ":00")),
    reliability = time - schedule,
    dwell = as.difftime(str_c("00:", Dwell)),
    travel = as.difftime(Travel),
    
    # change level descriptions for TSP thresholds
    threshold = factor(Threshold, levels = c("OFF", "5", "2", "ON"), 
                       labels = c("No TSP", "5 min", "2 min", "Always"))
  )

write_rds(processed_data, "data/uvx_timepoints.rds")
