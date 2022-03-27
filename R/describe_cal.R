describe_cal <- function(df, start_date=min(df$meetingStart), end_date=max(df$meetingEnd)) {
  # filter for selected date range
  df <- df[(lubridate::date(t$meetingStart) >= start_date) & (lubridate::date(t$meetingEnd) <= end_date),]
  
  # get count
  meeting_count <- nrow(df)
  
  # get length stats
  meeting_lengths <- as.numeric(df$meetingEnd - df$meetingStart)
  median_length <- median(meeting_lengths)
  q1_length <- quantile(meeting_lengths, 0.25)
  q3_length <- quantile(meeting_lengths, 0.75)
  
  # get attendee stats
  meeting_lengths <- as.numeric(df$meetingEnd - df$meetingStart)
  median_length <- stats::median(meeting_lengths)
  q1_length <- stats::quantile(meeting_lengths, 0.25)
  q3_length <- stats::quantile(meeting_lengths, 0.75)
  
  # get participants
  participants <- df$meetingAttendees %>% sapply(length) 
  # if 0 -> only organizer
  participants <- replace(participants, participants==0, 1)
  median_att <- stats::median(participants)
  q1_att <- stats::quantile(participants, 0.25)
  q3_att <- stats::quantile(participants, 0.75)
  
  return(dplyr::tibble("# of meetings" = meeting_count, 
                       "median meeting length (mins)" = median_length,
                       "1st quartile for meeting length (mins)" = q1_length,
                       "3rd quartile for meeting length (mins)" = q3_length,
                       "median # of attendees" = median_att,
                       "1st quartile for # of attendees" = q1_att, 
                       "3rd quartile for # of attendees" = q3_att) %>%
           tidyr::pivot_longer(cols = c("# of meetings",  "median meeting length (mins)",
                                        "1st quartile for meeting length (mins)", "3rd quartile for meeting length (mins)",
                                        "median # of attendees", "1st quartile for # of attendees",
                                        "3rd quartile for # of attendees"), names_to = 'summary_stat')
  )
}