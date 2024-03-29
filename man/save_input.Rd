% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epinow-internal.R
\name{save_input}
\alias{save_input}
\title{Save Observed Data}
\usage{
save_input(reported_cases, target_folder)
}
\arguments{
\item{reported_cases}{A data frame of confirmed cases (confirm) by date
(date). confirm must be integer and date must be in date format.}

\item{target_folder}{Character string specifying where to save results (will
create if not present).}
}
\value{
No return value, called for side effects
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
Saves observed data to a target location if given.
}
\author{
Sam Abbott
}
