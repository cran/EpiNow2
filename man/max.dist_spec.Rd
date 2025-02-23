% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_spec.R
\name{max.dist_spec}
\alias{max.dist_spec}
\title{Returns the maximum of one or more delay distribution}
\usage{
\method{max}{dist_spec}(x, ...)
}
\arguments{
\item{x}{The <dist_spec> to use}

\item{...}{Not used}
}
\value{
A vector of means.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
This works out the maximum of all the (parametric / nonparametric) delay
distributions combined in the passed <dist_spec> (ignoring any uncertainty
in parameters)
}
\examples{
# A fixed gamma distribution with mean 5 and sd 1.
dist1 <- Gamma(mean = 5, sd = 1, max = 20)
max(dist1)

# An uncertain lognormal distribution with meanlog and sdlog normally
# distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
dist2 <- LogNormal(
  meanlog = Normal(3, 0.5),
  sdlog = Normal(2, 0.5),
  max = 20
)
max(dist2)

# The max the sum of two distributions
max(dist1 + dist2)
}
