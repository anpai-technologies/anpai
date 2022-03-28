\name{dow_plot}
\alias{dow_plot}
\docType{package}
\title{
Plot stacked area percentage chart
}
\arguments{
  \item{df}{The anpai dataframe}
  \item{start}{Optional start date, Use Y-m-d to specify}
  \item{end}{Optional end date, Use Y-m-d to specify}
  \item{working_hours}{Optional end date, working hour vector of length 7 starting with with Sunday}
}
\description{
Plot stacked area percentage chart of time spent inside vs. outside of meetings
}
\usage{
dow_plot(df, start, end, working_hours)
}
\examples{
\dontrun{
dow_plot(df, 2022-01-01, 2022-01-12, c(0,8,8,8,8,8,0))
}
}
