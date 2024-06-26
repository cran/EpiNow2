% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epinow-internal.R
\name{estimates_by_report_date}
\alias{estimates_by_report_date}
\title{Estimate Cases by Report Date}
\usage{
estimates_by_report_date(
  estimates,
  CrIs = c(0.2, 0.5, 0.9),
  target_folder = NULL,
  samples = TRUE
)
}
\arguments{
\item{estimates}{List of data frames as output by \code{estimate_infections}}

\item{CrIs}{Numeric vector of credible intervals to calculate.}

\item{target_folder}{Character string specifying where to save results (will
create if not present).}

\item{samples}{Logical, defaults to TRUE. Should samples be saved}
}
\value{
A list of samples and summarised estimates of estimated cases by
date of report.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#questioning}{\figure{lifecycle-questioning.svg}{options: alt='[Questioning]'}}}{\strong{[Questioning]}}
Either extracts or converts reported cases from an input data table. For
output from \code{estimate_infections} this is a simple filtering step.
}
\keyword{internal}
