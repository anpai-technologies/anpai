cal_heatmap <- function(df) {
  
  # get days with meetings & aggregate
  meeting_days <- df %>% dplyr::mutate(date = lubridate::date(meetingStart),
                                       duration = as.integer(meetingEnd - meetingStart) / 60
  ) %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(tim = sum(duration)) %>%
    dplyr::mutate(day = as.integer(lubridate::day(date)),
                  mo = paste(as.character(lubridate::year(date)), '-', as.character(format(date, "%m"))),
                  dow = as.character(lubridate::wday(date))
    )
  
  # add days without meetings
  free_days <-  dplyr::tibble(date = seq(min(meeting_days$date, na.rm = T), max(meeting_days$date, na.rm = T), by="day")) %>%
    dplyr::mutate(
      tim = 0,
      day = as.integer(lubridate::day(date)),
      mo = paste(as.character(lubridate::year(date)), '-',  as.character(format(date, "%m"))),
      dow = as.character(lubridate::wday(date))
    ) 
  
  # merge both for plot
  all_days <- meeting_days %>% 
    dplyr::bind_rows(free_days) %>% 
    dplyr::distinct(date, .keep_all = TRUE) %>%
    cbind(wom = week_of_month(.)) %>%
    dplyr::mutate(wom = factor(wom, ordered = TRUE, 
                               levels = c("5","4", "3", "2", "1"))) %>%
    tidyr::drop_na(mo, dow) 
  
  # create heatmap
  ggplot2::ggplot(all_days, aes(x = dow, y = wom, fill = tim)) +
    ggplot2::facet_grid(mo ~ ., scales = "free") +
    ggplot2::geom_tile(width = .9, height = .9) + ylim("5", "4", "3", "2", "1", NA) +
    ggplot2::scale_fill_gradientn(colours = c("#a6aa9c", "#f5efe3", "#f7d3ba"), values = c(0, 0.5, 1)) +
    ggplot2::theme_minimal() + 
    ggplot2::scale_x_discrete(position = "top", labels=c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
    ggplot2::theme(axis.title.x=element_blank(),
                   axis.title.y=element_blank(),
                   axis.text.y=element_blank(),
                   axis.ticks.y=element_blank(),
                   panel.grid.major = element_blank(), 
                   panel.grid.minor = element_blank(),
                   text = element_text(size = 15),
                   plot.title = element_text(size = 18, margin=margin(0, 0, 30, 0))) +
    ggplot2::ggtitle("Meeting heatmap") +
    ggplot2::guides(fill=guide_legend(title="Meeting hours"))
  
}
