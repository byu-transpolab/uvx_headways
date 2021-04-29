library(targets)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
source("R/datamaker.R")
source("R/analysis.R")

options(dplyr.summarise.inform = FALSE)

# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse", "lubridate", "quantreg"))

# End this file with a list of target objects.
list(
  
  # primary data cleaning
  tar_target(timepoint_data, get_data("data/UVX_Reliability_2019.csv.zip")),
  tar_target(cleaned_data, clean_data(timepoint_data)),
  tar_target(headways, calculate_headways(cleaned_data)),
  
  
  # data analysis and tables
  tar_target(period_change_table, get_period_change(headways)),
  tar_target(ecdf, make_ecdf(headways)),
  tar_target(models, qr_estimate(headways))
)

