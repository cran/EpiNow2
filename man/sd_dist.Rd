% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_spec.R
\name{sd_dist}
\alias{sd_dist}
\title{Returns the standard deviation of one or more delay distribution}
\usage{
sd_dist(x)
}
\arguments{
\item{x}{The \code{\link[=dist_spec]{dist_spec()}} to use}
}
\value{
A vector of standard deviations.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
This works out the standard deviation of all the (parametric /
nonparametric) delay distributions combined in the passed \code{\link[=dist_spec]{dist_spec()}}.
}
\examples{
\dontrun{
# A fixed lognormal distribution with sd 5 and sd 1.
dist1 <- LogNormal(mean = 5, sd = 1, max = 20)
sd_dist(dist1)

# A gamma distribution with mean 3 and sd 2
dist2 <- Gamma(mean = 3, sd = 2)
sd_dist(dist2)

# The sd of the sum of two distributions
sd_dist(dist1 + dist2)
}
}
\keyword{internal}
