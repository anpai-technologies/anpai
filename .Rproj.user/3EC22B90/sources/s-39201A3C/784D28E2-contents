read_ics <- function(path) {
  # use rcpp function to read
  temp <- read_ics_rcpp(path)
  
  # unpack attendees
  temp$meetingAttendees <- temp$meetingAttendees %>%
    str_replace_all("ATTENDEE", "") %>%
    str_extract_all('([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z0-9_-]+)') %>%
    sapply(., unique)
  
  return(temp)
}