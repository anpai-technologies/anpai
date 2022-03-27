\name{change_tz}
\alias{change_tz}
\docType{package}
\title{
Change the timezone in an anpai df
}
\arguments{
  \item{df}{The anpai dataframe}
  \item{new_tz}{The timezone to convert the time-related columns to.}
}
\description{
Converts the timezones of {meetingStart, meetingEnd, meetingLastModified} to the specified destination timezone. Check valid names using lubridate::OlsonNames()
}
\usage{
change_tz(df, new_tz)
}
\examples{
\dontrun{
change_tz(df, "America/New_York")
}
}
