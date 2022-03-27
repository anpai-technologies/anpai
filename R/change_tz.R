change_tz <- function(df, new_tz) {
  df_cols <- colnames(df)
  if ((!"meetingEnd" %in% df_cols) || (!"meetingStart" %in% df_cols)
      || (!"meetingLastModified" %in% df_cols)) { 
    # break if columns from anpai df not present in passed df
    stop("Not all of {meetingStart, meetingEnd, meetingLastModified} in columns.")
  } else {
    # use lubridate to force & then convert timezones to specified 'new_tz'
    df <- df %>% mutate(
      meetingStart = lubridate::with_tz(lubridate::force_tz(df$meetingStart, "UTC"), new_tz),
      meetingEnd = lubridate::with_tz(lubridate::force_tz(df$meetingEnd, "UTC"), new_tz),
      meetingLastModified = lubridate::with_tz(lubridate::force_tz(df$meetingLastModified, "UTC"), new_tz)
    )
    return(df)
  }
}