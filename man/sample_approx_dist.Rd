% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecated.R
\name{sample_approx_dist}
\alias{sample_approx_dist}
\title{Approximate Sampling a Distribution using Counts}
\usage{
sample_approx_dist(
  cases = NULL,
  dist_fn = NULL,
  max_value = 120,
  earliest_allowed_mapped = NULL,
  direction = "backwards",
  type = "sample",
  truncate_future = TRUE
)
}
\arguments{
\item{cases}{A \verb{<data.frame>} of cases (in date order) with the following
variables: \code{date} and \code{cases}.}

\item{dist_fn}{Function that takes two arguments with the first being
numeric and the second being logical (and defined as \code{dist}). Should return
the probability density or a sample from the defined distribution. See
the examples for more.}

\item{max_value}{Numeric, maximum value to allow. Defaults to 120 days}

\item{earliest_allowed_mapped}{A character string representing a date
("2020-01-01"). Indicates the earliest allowed mapped value.}

\item{direction}{Character string, defato "backwards". Direction in which to
map cases. Supports either "backwards" or "forwards".}

\item{type}{Character string indicating the method to use to transform
counts. Supports either "sample"  which approximates sampling or "median"
would shift by the median of the distribution.}

\item{truncate_future}{Logical, should cases be truncated if they occur
after the first date reported in the data. Defaults to \code{TRUE}.}
}
\value{
A \verb{<data.table>} of cases by date of onset
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}
Convolves cases by a PMF function. This function will soon be removed or
replaced with a more robust stan implementation.
}
\examples{
\donttest{
cases <- example_confirmed
cases <- cases[, cases := as.integer(confirm)]
print(cases)

# total cases
sum(cases$cases)

delay_fn <- function(n, dist, cum) {
  if (dist) {
    pgamma(n + 0.9999, 2, 1) - pgamma(n - 1e-5, 2, 1)
  } else {
    as.integer(rgamma(n, 2, 1))
  }
}

onsets <- sample_approx_dist(
  cases = cases,
  dist_fn = delay_fn
)

# estimated onset distribution
print(onsets)

# check that sum is equal to reported cases
total_onsets <- median(
  purrr::map_dbl(
    1:10,
    ~ sum(sample_approx_dist(
      cases = cases,
      dist_fn = delay_fn
    )$cases)
  )
)
total_onsets


# map from onset cases to reported
reports <- sample_approx_dist(
  cases = cases,
  dist_fn = delay_fn,
  direction = "forwards"
)


# map from onset cases to reported using a mean shift
reports <- sample_approx_dist(
  cases = cases,
  dist_fn = delay_fn,
  direction = "forwards",
  type = "median"
)
}
}
\keyword{internal}
