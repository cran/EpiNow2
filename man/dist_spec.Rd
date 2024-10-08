% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecated.R
\name{dist_spec}
\alias{dist_spec}
\title{Specify a distribution.}
\usage{
dist_spec(
  distribution = c("lognormal", "normal", "gamma", "fixed", "empty"),
  params_mean = numeric(0),
  params_sd = numeric(0),
  max = Inf,
  pmf = numeric(0),
  fixed = FALSE
)
}
\arguments{
\item{distribution}{Character, defaults to "lognormal". The (discretised)
distribution to be used. Can be "lognormal", "gamma", "normal" or "fixed".
The corresponding parameters (defined in \code{\link[=natural_params]{natural_params()}}) are passed
as \code{params_mean},  and their uncertainty as \code{params_sd}.}

\item{params_mean}{Numeric. Central values of the parameters of the
distribution as defined in [natural_params().}

\item{params_sd}{Numeric. Standard deviations of the parameters of the
distribution as defined in [natural_params().}

\item{max}{Numeric, maximum value of the distribution. The distribution will
be truncated at this value. Default: \code{Inf}, i.e. no maximum.}

\item{pmf}{Numeric, a vector of values that represent the (nonparametric)
probability mass function of the delay (starting with 0); defaults to an
empty vector corresponding to a parametric specification of the distribution
(using \code{params_mean}, and \code{params_sd}.}

\item{fixed}{Deprecated, use \code{\link[=fix_parameters]{fix_parameters()}} instead.}
}
\value{
A list of distribution options.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}
This function is deprecated as a user-facing function (while its
functionality is still used internally). Construct distributions using
the corresponding distribution function such as \code{\link[=Gamma]{Gamma()}}, \code{\link[=LogNormal]{LogNormal()}},
\code{\link[=Normal]{Normal()}} or \code{\link[=Fixed]{Fixed()}} instead.
}
\keyword{internal}
