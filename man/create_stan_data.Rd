% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create.R
\name{create_stan_data}
\alias{create_stan_data}
\title{Create Stan Data Required for estimate_infections}
\usage{
create_stan_data(
  reported_cases,
  generation_time,
  rt,
  gp,
  obs,
  delays,
  horizon,
  backcalc,
  shifted_cases,
  truncation
)
}
\arguments{
\item{reported_cases}{A data frame of confirmed cases (confirm) by date (date). confirm must be integer and date must be
in date format.}

\item{generation_time}{A list containing the mean, standard deviation of the mean (mean_sd),
standard deviation (sd), standard deviation of the standard deviation and the maximum allowed value for the
generation time (assuming a gamma distribution).}

\item{rt}{A list of options as generated by \code{rt_opts()} defining Rt estimation.
Defaults to \code{rt_opts()}. Set to \code{NULL} to switch to using  back calculation
rather than generating infections using Rt.}

\item{gp}{A list of options as generated by \code{gp_opts()} to define the
Gaussian process. Defaults to \code{gp_opts()}.Set to NULL to disable the
Gaussian process.}

\item{obs}{A list of options as generated by \code{obs_opts()} defining the
observation model. Defaults to \code{obs_opts()}.}

\item{delays}{A call to \code{delay_opts()} defining delay distributions and options. See the documentation of \code{delay_opts()}
and the examples below for details.}

\item{horizon}{Numeric, forecast horizon.}

\item{backcalc}{A list of options as generated by \code{backcalc_opts()} to define the
back calculation. Defaults to \code{backcalc_opts()}.}

\item{shifted_cases}{A dataframe of delay shifted cases}

\item{truncation}{\ifelse{html}{\out{<a href='https://www.tidyverse.org/lifecycle/#experimental'><img src='figures/lifecycle-experimental.svg' alt='Experimental lifecycle'></a>}}{\strong{Experimental}} A list of options as generated by \code{trunc_opts()}
defining the truncation of observed data. Defaults to \code{trunc_opts()}. See \code{estimate_truncation()}
for an approach to estimating truncation from data.}
}
\value{
A list of stan data
}
\description{
\ifelse{html}{\out{<a href='https://www.tidyverse.org/lifecycle/#stable'><img src='figures/lifecycle-stable.svg' alt='Stable lifecycle'></a>}}{\strong{Stable}}
Takes the output of \code{stan_opts()} and converts it into a list understood by \code{stan}. Internally
calls the other \code{create_} family of functions to construct a single list for input into stan
with all data required present.
}
