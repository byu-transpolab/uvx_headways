#' Get data and read
#' 
#' @param raw_file Path to raw file in local directory
#' @return A tibble with raw timepoint data
#' 
get_data <- function(raw_file){
  if(!file.exists(raw_file)){
    download.file("https://byu.box.com/shared/static/nkf9nh63oqp501ech59urzzi738sio5l.zip", raw_file)
  }
  read_csv(
    raw_file, 
    # read everything in as a character string
    col_types = str_c(rep("c", 24), collapse = "") 
  )
}

#' Clean timepoint data
#' @param timepoint_data Raw timepoint data, read in with `get_data()`
#' @return cleaned timepoint data
clean_data <- function(timepoint_data){
  timepoint_data %>%
    transmute(
      # Route and direction IDs
      route = Route, direction = substr(Direction, 0, 2), 
      trip = Trip,
      timepoint = `Time Point`,
      vehicle = Vehicle,
      
      # Time points
      date = as_date(mdy(NEW_Date)),
      time = as_datetime(str_c(mdy(NEW_Date), " ", DepartureTime)),
      period = case_when(
        hour(time) %in% c(7, 8, 9) ~ c("AM Peak"),
        hour(time) %in% c(16, 17, 18) ~ c("PM Peak"),
        TRUE ~ "Off Peak"
      ),
      schedule = as_datetime(str_c(mdy(NEW_Date), " ", Schedule, ":00")),
      reliability = time - schedule,
      dwell = as.difftime(str_c("00:", Dwell)),
      travel = as.difftime(Travel),
      
      # change level descriptions for TSP thresholds
      threshold = factor(Threshold, levels = c("OFF", "5", "2", "ON"), 
                         labels = c("No TSP", "5 min", "2 min", "Always"))
    ) %>%
    filter(!is.na(threshold)) %>%
    
    # remove dates during the school year
    filter(
      date > as_date("2019-05-01"),
      date < as_date("2019-08-31")
    ) %>%
    
    # only keep weekdays
    filter(wday(time) %in% c(2:5)) %>%
    # only keep timepoints between 7 AM and 8 PM.
    filter(hour(time) >= 7, hour(time) <= 20) %>%
    # get rid of east bay and endpoints
    filter(!timepoint %in% c(
      "EASTBAYN", "EASTBAYS", "PROVFRST - 1",  "PROVFRST - 2", "TOWNCNTR - 1", 
      "TOWNCNTR - 2", "PROVFRST",  "OREMFRST"))

}

#' Calculate headway information
#' 
#' @param cleaned_data timepoint data that has been cleaned and filtered.
#' @return cleaned data, but with computed headways.
calculate_headways <- function(cleaned_data){
  cleaned_data %>%
    # This is a test filter that has come in handy
    # a group is a date, direction, and timepoint (stop). Arranging
    # by time will give a table where each successive row will contain the 
    # next arriving vehicle at that stop.
    group_by(direction, date, timepoint) %>%
    arrange(time, .by_group = TRUE) %>%
    mutate(
      hw_schd = lead(schedule) - schedule, # scheduled headway: different in schedules
    ) %>% 
    mutate(
      hw_actl = lead(time) - time, # actual headway: difference in recorded times
      discrepancy = hw_schd - hw_actl # difference between actual and scheduled hw
    ) %>%
    # only keep trips from when we're running at 6-minute headways
    filter(hw_schd %in% c(360, 600)) %>%
    # Now, group by direction and trip to calculate cumulative dwell time
    group_by(direction, trip, date) %>%
    arrange(time, .by_group = TRUE) %>%
    mutate(
      cumdwell = cumsum(as.numeric(dwell))
    )
}



