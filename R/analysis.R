#' Determine when the experiment switched threshold values
#' 
#' @param headways headway data
#' @return A tibble showing when experiment periods started and ended
#' 
get_period_change <- function(headways){
  headways %>%
    arrange(time) %>%
    mutate(
      tchange = ifelse(threshold == lead(threshold), FALSE, TRUE),
      tperiod = cumsum(tchange)
    ) %>%
    group_by(tperiod, threshold) %>%
    summarise(start = min(date), end = max(date), n = n()) %>%
    filter(!is.na(tperiod)) %>% ungroup() %>%
    arrange(start)
}

#' Create a plot of the cumulative density function
#' 
#' @param headways
#' @return a ggplot2 object
make_ecdf <- function(headways){
  headways %>% 
    ggplot(aes(x = as.numeric(hw_actl) / 60, color = threshold)) +
    stat_ecdf() +
    coord_cartesian(xlim = c(0, 10))
}

#' Calculate average discrepancy by group
#' 
#' @param headways
#' 
avg_discrepancy <- function(headways){
  roundd <- function(x) round(x, digits = 4)
  headways %>%
    group_by(threshold) %>%
    mutate(r = discrepancy) %>%
    summarise(
      p10 = quantile(r, probs = 0.10),
      median = median(r),
      mean = mean(r), 
      p75 = quantile(r, probs = 0.75),
      p85 = quantile(r, probs = 0.85),
      p95 = quantile(r, probs = 0.95)
    ) %>%
    mutate_if(is.numeric, roundd)
}


p85_discrepancy <- function(headways){
  headways %>%
    group_by(threshold, direction) %>%
    summarise(
      p85 = quantile(discrepancy, probs = 0.85)
    )
}



qr_estimate <- function(headways){
  data <- headways %>%
    mutate(
      discrepancy = as.numeric(discrepancy)/60,
      period = factor(period),
      period = fct_relevel(period, "Off Peak")
    )
  qfit_thold <- rq(hw_actl ~ threshold, tau = 0.85, data = data)
  qfit_dir <- update(qfit_thold, .~. + direction)
  qfit_pk  <- update(qfit_thold, .~. + period)
  qfit_dirpk <- update(qfit_thold, .~. + direction*period)
  
  
  list(
    "Threshold" = qfit_thold,
    "Direction" = qfit_dir,
    "Peak" = qfit_pk,
    "All"  = qfit_dirpk
  )
}




