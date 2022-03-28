dow_plot <- function(df, start, end, working_hours) {
  
  if (missing(start)) {
    start=min(df$meetingStart)
  }
  if (missing(end)) {
    end=max(df$meetingEnd)
  }
  if (missing(working_hours)) {
    working_hours=c(0,8,8,8,8,8,0)
  }
  
  # get time spent in meetings
  plt_df <- df %>%
              dplyr::mutate(meetingLengths = as.numeric(meetingEnd-meetingStart),
                              DOW = lubridate::wday(meetingStart, label=T, abbr=F)) %>%
              dplyr::group_by(DOW) %>%
              dplyr::summarize(timeInMeetings = sum(meetingLengths)/60) %>% 
              dplyr::ungroup() 
  
  # get working days & corresponding total working hours
  new_plt_df <- dplyr::tibble(days = seq(lubridate::date(start), lubridate::date(end), by="day")) %>%
                  dplyr::mutate(DOW = lubridate::wday(days, label=T, abbr=F))  %>%
                  dplyr::group_by(DOW) %>%
                  dplyr::summarize(dow_n = dplyr::n()) %>%
                  dplyr::ungroup() %>%
                  dplyr::mutate(total_hours = dow_n * working_hours) %>%
                  dplyr::left_join(plt_df, by="DOW") %>%
                  dplyr::mutate(timeInMeetings = tidyr::replace_na(timeInMeetings, 0),
                         `Meeting Time` = dplyr::if_else(total_hours==0, 0, timeInMeetings/total_hours),
                         `Non-Meeting Time` = 1-`Meeting Time`
                        ) %>%
                  dplyr::select(DOW, `Meeting Time`, `Non-Meeting Time`) %>%
                  dplyr::pivot_longer(-DOW)
  
  # create stacked area chart
  plt <- ggplot2::ggplot(new_plt_df, ggplot2::aes(x=rep(seq(1,7),each=2), y=value, fill=name)) + 
          ggplot2::geom_area(alpha=0.8, color = "white", lwd = 1, linetype = 1) + 
          ggplot2::scale_fill_manual(values=c("#f7d3ba", "#a6aa9c")) +
          ggplot2::scale_x_continuous(limits = c(1,7), expand = c(0, 0), 
                                        labels=c("Sun", "Mo", "Tue", "Wed", "Thu", "Fri", "Sat")) +
          ggplot2::scale_y_continuous(limits = c(0,1), expand = c(0, 0), 
                                        breaks=c(0.25, 0.5, 0.75,  1),
                                        labels=c("25%", "50%", "75%", "100%")) +
          ggplot2::theme_bw() +
          ggplot2::theme(panel.grid = ggplot2::element_blank(),
                          panel.border = ggplot2::element_blank(),
                          axis.ticks = ggplot2::element_blank(),
                          text = ggplot2::element_text(size=14)) +
          ggplot2::labs(y = "Working Hours", x = "Day of Week", 
                          title = "Time Spent In Vs. Out of Meetings", fill = "Legend")
  
  return(plt)
}
