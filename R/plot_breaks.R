plot_breaks <- function(df) {
  
  # get next week
  diff <- 2 - lubridate::wday(lubridate::today())
  if ( diff < 0 ) {
    diff <- diff + 7 
  }
  df <- df %>% 
    dplyr::filter(meetingStart >= lubridate::today() + diff) %>% 
    dplyr::filter(meetingStart <= lubridate::today() + diff + 5) %>% 
    dplyr::arrange(meetingStart) %>% 
    tidyr::drop_na(meetingStart)
  
  # get break times
  timeBetweenMeetings <- c(nrow(df))
  for (i in 1:nrow(df))  {
    if ( (date(df$meetingStart[i]) ==  date(df$meetingStart[i-1])) && i >= 2 ) {
      timeBetweenMeetings[i] = as.numeric((hour(df$meetingStart[i]) + minute(df$meetingStart[i])/60)
                                          - (hour(df$meetingEnd[i-1]) + minute(df$meetingEnd[i-1])/60))
    } else {
      timeBetweenMeetings[i] = NA
    }
  }
  df$breaks <- timeBetweenMeetings
  
  # create plot
  suppressWarnings(
    df %>% tidyr::drop_na(breaks) %>%
      dplyr::group_by(lubridate::date(meetingStart)) %>%
      dplyr::summarize(median_break = median(breaks))  %>%
      dplyr::filter(median_break >= 0) %>%
      ggplot2::ggplot(aes(`lubridate::date(meetingStart)`, median_break)) +  
      ggplot2::theme_minimal() +
      ggplot2::scale_y_continuous(limit=c(0,NA)) +
      ggplot2::geom_rect(mapping=aes(xmin=min(`lubridate::date(meetingStart)`), xmax=max(`lubridate::date(meetingStart)`), 
                                     ymin=0, ymax=1/3,fill="Meeting notes")) +
      ggplot2::geom_rect(mapping=aes(xmin=min(`lubridate::date(meetingStart)`), xmax=max(`lubridate::date(meetingStart)`), 
                                     ymin=1/3, ymax=2/3, fill="Small admin tasks")) +
      ggplot2::geom_rect(mapping=aes(xmin=min(`lubridate::date(meetingStart)`), xmax=max(`lubridate::date(meetingStart)`), 
                                     ymin=1, ymax=max(median_break)+0.1,fill="Real focus time")) +
      ggplot2::geom_rect(mapping=aes(xmin=min(`lubridate::date(meetingStart)`), xmax=max(`lubridate::date(meetingStart)`), 
                                     ymin=2/3, ymax=1, fill="Medium complexity tasks")) +
      ggplot2::geom_smooth(formula = y ~ x, method = "loess", se = FALSE, color="black") +
      ggplot2::geom_point(size=4) + 
      ggplot2::ylab("Median Break Time (H)") +
      ggplot2::xlab("Date") +
      ggplot2::ggtitle("What you'll get done between meetings next week") +
      ggplot2::theme(axis.text.x = element_text(vjust = 7),
                     axis.title.y = element_text(vjust = 2.2),
                     panel.grid.major = element_blank(), 
                     panel.grid.minor = element_blank(), 
                     text = element_text(size = 15),
                     plot.title = element_text(size = 18, margin=margin(0, 0, 30, 0))) +
      ggplot2::scale_fill_manual(name='What you\'ll get done',
                                 breaks=c('Meeting notes', 'Small admin tasks', 'Medium complexity tasks', 'Real focus time'),
                                 values=c('Meeting notes'='#f7d3ba', 'Small admin tasks'='#f5efe3', 'Medium complexity tasks'='#e6e7e5', 'Real focus time'='#a6aa9c'))
  )
}