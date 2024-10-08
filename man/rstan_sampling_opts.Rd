% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecated.R
\name{rstan_sampling_opts}
\alias{rstan_sampling_opts}
\title{Rstan Sampling Options}
\usage{
rstan_sampling_opts(
  cores = getOption("mc.cores", 1L),
  warmup = 250,
  samples = 2000,
  chains = 4,
  control = list(),
  save_warmup = FALSE,
  seed = as.integer(runif(1, 1, 1e+08)),
  future = FALSE,
  max_execution_time = Inf,
  ...
)
}
\arguments{
\item{cores}{Number of cores to use when executing the chains in parallel,
which defaults to 1 but it is recommended to set the mc.cores option to be
as many processors as the hardware and RAM allow (up to the number of
chains).}

\item{warmup}{Numeric, defaults to 250. Number of warmup samples per chain.}

\item{samples}{Numeric, default 2000. Overall number of posterior samples.
When using multiple chains iterations per chain is samples / chains.}

\item{chains}{Numeric, defaults to 4. Number of MCMC chains to use.}

\item{control}{List, defaults to empty. control parameters to pass to
underlying \code{rstan} function. By default \code{adapt_delta = 0.9} and
\code{max_treedepth = 12} though these settings can be overwritten.}

\item{save_warmup}{Logical, defaults to FALSE. Should warmup progress be
saved.}

\item{seed}{Numeric, defaults uniform random number between 1 and 1e8. Seed
of sampling process.}

\item{future}{Logical, defaults to \code{FALSE}. Should stan chains be run in
parallel using \code{future}. This allows users to have chains fail gracefully
(i.e when combined with \code{max_execution_time}). Should be combined with a
call to \code{\link[future:plan]{future::plan()}}.}

\item{max_execution_time}{Numeric, defaults to Inf (seconds). If set wil
kill off processing of each chain if not finished within the specified
timeout. When more than 2 chains finish successfully estimates will still be
returned. If less than 2 chains return within the allowed time then
estimation will fail with an informative error.}

\item{...}{Additional parameters to pass to \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}}.}
}
\value{
A list of arguments to pass to \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}}.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}
Deprecated; use \code{\link[=stan_sampling_opts]{stan_sampling_opts()}} instead.
}
