#' Estimate Truncation of Observed Data
#'
#' @description `r lifecycle::badge("stable")`
#' Estimates a truncation distribution from multiple snapshots of the same
#' data source over time. This distribution can then be used in
#' `regional_epinow`, `epinow`, and `estimate_infections` to adjust for
#' truncated data. See
#' [here](https://gist.github.com/seabbs/176b0c7f83eab1a7192a25b28bbd116a)
#' for an example of using this approach on Covid-19 data in England. The
#' functionality offered by this function is now available in a more principled
#' manner in the [`epinowcast` R package](https://package.epinowcast.org/).
#'
#' The model of truncation is as follows:
#'
#' 1. The truncation distribution is assumed to be discretised log normal wit
#' a mean and standard deviation that is informed by the data.
#'
#' 2. The data set with the latest observations is adjusted for truncation using
#' the truncation distribution.
#'
#' 3. Earlier data sets are recreated by applying the truncation distribution to
#' the adjusted latest observations in the time period of the earlier data set.
#' These data sets are then compared to the earlier observations assuming a
#' negative binomial observation model with an additive noise term to deal with
#' zero observations.
#'
#' This model is then fit using `stan` with standard normal, or half normal,
#' prior for the mean, standard deviation, 1 over the square root of the
#' overdispersion and additive noise term.
#'
#' This approach assumes that:
#'  - Current truncation is related to past truncation.
#'  - Truncation is a multiplicative scaling of underlying reported cases.
#'  - Truncation is log normally distributed.
#'
#' @param obs A list of data frames each containing a date variable
#' and a confirm (integer) variable. Each data set should be a snapshot
#' of the reported data over time. All data sets must contain a complete vector
#' of dates.
#'
#' @param max_truncation Deprecated; use `truncation` instead.
#'
#' @param trunc_max Deprecated; use `truncation` instead.
#'
#' @param trunc_dist Deprecated; use `truncation` instead.
#'
#' @param model A compiled stan model to override the default model. May be
#' useful for package developers or those developing extensions.
#'
#' @param weigh_delay_priors Logical. If TRUE, all delay distribution priors
#' will be weighted by the number of observation data points, in doing so
#' approximately placing an independent prior at each time step and usually
#' preventing the posteriors from shifting. If FALSE (default), no weight will
#' be applied, i.e. delay distributions will be treated as a single
#' parameters.
#'
#' @param verbose Logical, should model fitting progress be returned.
#'
#' @param ... Additional parameters to pass to `rstan::sampling`.
#'
#' @return A list containing: the summary parameters of the truncation
#'  distribution (`dist`), the estimated CMF of the truncation distribution
#' (`cmf`, can be used to adjusted new data), a data frame containing the
#' observed truncated data, latest observed data and the adjusted for
#' truncation observations (`obs`), a data frame containing the last
#' observed data (`last_obs`, useful for plotting and validation), the data
#' used for fitting (`data`) and the fit object (`fit`).
#'
#' @author Sam Abbott
#' @author Sebastian Funk
#' @export
#' @inheritParams calc_CrIs
#' @inheritParams estimate_infections
#' @importFrom purrr map reduce map_dbl
#' @importFrom rstan sampling
#' @importFrom data.table copy .N as.data.table merge.data.table setDT
#' @importFrom data.table setcolorder
#' @examples
#' # set number of cores to use
#' old_opts <- options()
#' options(mc.cores = ifelse(interactive(), 4, 1))
#'
#' # get example case counts
#' reported_cases <- example_confirmed[1:60]
#'
#' # define example truncation distribution (note not integer adjusted)
#' trunc <- dist_spec(
#'   mean = convert_to_logmean(3, 2),
#'   mean_sd = 0.1,
#'   sd = convert_to_logsd(3, 2),
#'   sd_sd = 0.1,
#'   max = 10
#' )
#'
#' # apply truncation to example data
#' construct_truncation <- function(index, cases, dist) {
#'   set.seed(index)
#'   if (dist$dist == 0) {
#'     dfunc <- dlnorm
#'   } else {
#'     dfunc <- dgamma
#'   }
#'   cmf <- cumsum(
#'     dfunc(
#'       1:(dist$max + 1),
#'       rnorm(1, dist$mean_mean, dist$mean_sd),
#'       rnorm(1, dist$sd_mean, dist$sd_sd)
#'     )
#'   )
#'   cmf <- cmf / cmf[dist$max + 1]
#'   cmf <- rev(cmf)[-1]
#'   trunc_cases <- data.table::copy(cases)[1:(.N - index)]
#'   trunc_cases[
#'     (.N - length(cmf) + 1):.N, confirm := as.integer(confirm * cmf)
#'   ]
#'   return(trunc_cases)
#' }
#' example_data <- purrr::map(c(20, 15, 10, 0),
#'   construct_truncation,
#'   cases = reported_cases,
#'   dist = trunc
#' )
#'
#' # fit model to example data
#' est <- estimate_truncation(example_data,
#'   verbose = interactive(),
#'   chains = 2, iter = 2000
#' )
#'
#' # summary of the distribution
#' est$dist
#' # summary of the estimated truncation cmf (can be applied to new data)
#' print(est$cmf)
#' # observations linked to truncation adjusted estimates
#' print(est$obs)
#' # validation plot of observations vs estimates
#' plot(est)
#'
#' options(old_opts)
estimate_truncation <- function(obs, max_truncation, trunc_max = 10,
                                trunc_dist = "lognormal",
                                truncation = dist_spec(
                                  mean = 0, sd = 0, mean_sd = 1, sd_sd = 1,
                                  max = 10
                                ),
                                model = NULL,
                                CrIs = c(0.2, 0.5, 0.9),
                                weigh_delay_priors = FALSE,
                                verbose = TRUE,
                                ...) {

  ## code block to remove in EpiNow2 2.0.0
  construct_trunc <- FALSE
  if (!missing(trunc_max)) {
    if (!missing(truncation)) {
      stop(
        "`trunc_max` and `truncation` arguments are both given. ",
        "Use only `truncation` instead.")
    }
    if (!missing(max_truncation)) {
      stop(
        "`max_truncation` and `trunc_max` arguments are both given. ",
        "Use only `truncation` instead.")
    }
    deprecate_warn(
      "1.4.0",
      "estimate_truncation(trunc_max)",
      "estimate_truncation(truncation)",
      "The argument will be removed completely in version 2.0.0."
    )
    construct_trunc <- TRUE
  }
  if (!missing(max_truncation)) {
    if (!missing(truncation)) {
      stop(
        "`max_truncation` and `truncation` arguments are both given. ",
        "Use only `truncation` instead.")
    }
    deprecate_warn(
      "1.4.0",
      "estimate_truncation(max_truncation)",
      "estimate_truncation(truncation)",
      "The argument will be removed completely in version 2.0.0."
    )
    trunc_max <- max_truncation
    construct_trunc <- TRUE
  }
  if (!missing(trunc_dist)) {
    trunc_dist <- match.arg(trunc_dist)
    if (!missing(truncation)) {
      stop(
        "`trunc_dist` and `truncation` arguments are both given. ",
        "Use only `truncation` instead.")
    }
    deprecate_warn(
      "1.4.0",
      "estimate_truncation(trunc_dist)",
      "estimate_truncation(truncation)",
      "The argument will be removed completely in version 2.0.0."
    )
    construct_trunc <- TRUE
  }
  if (construct_trunc) {
    truncation <- dist_spec(
      mean = 0, mean_sd = 1, sd = 0, sd_sd = 1, distribution = trunc_dist,
      max = trunc_max
    )
  }

  # combine into ordered matrix
  dirty_obs <- purrr::map(obs, data.table::as.data.table)
  nrow_obs <- order(purrr::map_dbl(dirty_obs, nrow))
  dirty_obs <- dirty_obs[nrow_obs]
  obs <- purrr::map(dirty_obs, data.table::copy)
  obs <- purrr::map(seq_along(obs), ~ obs[[.]][, (as.character(.)) := confirm][
    ,
    confirm := NULL
  ])
  obs <- purrr::reduce(obs, merge, all = TRUE)
  obs_start <- max(nrow(obs) - trunc_max - sum(is.na(obs$`1`)) + 1, 1)
  obs_dist <- purrr::map_dbl(2:(ncol(obs)), ~ sum(is.na(obs[[.]])))
  obs_data <- obs[, -1][, purrr::map(.SD, ~ ifelse(is.na(.), 0, .))]
  obs_data <- obs_data[obs_start:.N]

  # convert to stan list
  data <- list(
    obs = obs_data,
    obs_dist = obs_dist,
    t = nrow(obs_data),
    obs_sets = ncol(obs_data)
  )

  data <- c(data, create_stan_delays(
    trunc = truncation,
    weight = ifelse(weigh_delay_priors, data$t, 1)
  ))

  ## convert to integer
  data$trunc_dist <-
    which(eval(formals()[["trunc_dist"]]) == trunc_dist) - 1

  # initial conditions
  init_fn <- function() {
    data <- list(
      delay_mean = array(rnorm(1, 0, 1)),
      delay_sd = array(abs(rnorm(1, 0, 1))) + 1,
      phi = abs(rnorm(1, 0, 1)),
      sigma = abs(rnorm(1, 0, 1))
    )
    return(data)
  }

  # fit
  if (is.null(model)) {
    model <- stanmodels$estimate_truncation
  }
  fit <- rstan::sampling(model,
    data = data,
    init = init_fn,
    refresh = ifelse(verbose, 50, 0),
    ...
  )

  out <- list()
  # Summarise fit truncation distribution for downstream usage
  out$dist <- dist_spec(
    mean = round(rstan::summary(fit, pars = "delay_mean")$summary[1], 3),
    mean_sd = round(rstan::summary(fit, pars = "delay_mean")$summary[3], 3),
    sd = round(rstan::summary(fit, pars = "delay_sd")$summary[1], 3),
    sd_sd = round(rstan::summary(fit, pars = "delay_sd")$summary[3], 3),
    max = truncation$max
  )
  out$dist$dist <- truncation$dist

  # summarise reconstructed observations
  recon_obs <- extract_stan_param(fit, "recon_obs",
    CrIs = CrIs,
    var_names = TRUE
  )
  recon_obs <- recon_obs[, id := variable][, variable := NULL]
  recon_obs <- recon_obs[, dataset := seq_len(.N)][
    ,
    dataset := dataset %% data$obs_sets
  ][
    dataset == 0, dataset := data$obs_sets
  ]
  # link reconstructed observations to observed
  last_obs <-
    data.table::copy(dirty_obs[[length(dirty_obs)]])[, last_confirm := confirm][
      ,
      confirm := NULL
    ]
  link_obs <- function(index) {
    target_obs <- dirty_obs[[index]][, index := .N - 0:(.N - 1)]
    target_obs <- target_obs[index < trunc_max]
    estimates <- recon_obs[dataset == index][, c("id", "dataset") := NULL]
    estimates <- estimates[, lapply(.SD, as.integer)]
    estimates <- estimates[, index := .N - 0:(.N - 1)]
    if (!is.null(estimates$n_eff)) {
      estimates[, "n_eff" := NULL]
    }
    if (!is.null(estimates$Rhat)) {
      estimates[, "Rhat" := NULL]
    }

    target_obs <-
      data.table::merge.data.table(
        target_obs, last_obs,
        by = "date"
      )
    target_obs[, report_date := max(date)]
    target_obs <- data.table::merge.data.table(target_obs, estimates,
      by = "index", all.x = TRUE
    )
    target_obs <- target_obs[order(date)][, index := NULL]
    return(target_obs)
  }
  out$obs <- purrr::map(1:(data$obs_sets), link_obs)
  out$obs <- data.table::rbindlist(out$obs)
  out$last_obs <- last_obs
  # summarise estimated cmf of the truncation distribution
  out$cmf <- extract_stan_param(fit, "trunc_rev_cmf", CrIs = CrIs)
  out$cmf <- data.table::as.data.table(out$cmf)[, index := seq_len(.N)]
  data.table::setcolorder(out$cmf, "index")
  out$data <- data
  out$fit <- fit

  class(out) <- c("estimate_truncation", class(out))
  return(out)
}

#' Plot method for estimate_truncation
#'
#' @description `r lifecycle::badge("experimental")`
#' `plot` method for class "estimate_truncation". Returns
#' a plot faceted over each dataset used in fitting with the latest
#' observations as columns, the data observed at the time (and so truncated)
#' as dots and the truncation adjusted estimates as a ribbon.
#'
#' @param x A list of output as produced by `estimate_truncation`
#'
#' @param ... Pass additional arguments to plot function. Not currently in use.
#'
#' @return `ggplot2` object
#' @author Sam Abbott
#' @seealso plot estimate_truncation
#' @method plot estimate_truncation
#' @importFrom ggplot2 ggplot aes geom_col geom_point labs scale_x_date
#' @importFrom ggplot2 scale_y_continuous theme theme_bw
#' @export
plot.estimate_truncation <- function(x, ...) {
  plot <- ggplot2::ggplot(x$obs, ggplot2::aes(x = date, y = last_confirm)) +
    ggplot2::geom_col(
      fill = "grey", col = "white",
      show.legend = FALSE, na.rm = TRUE
    ) +
    ggplot2::geom_point(
      data = x$obs,
      ggplot2::aes(x = date, y = confirm)
    ) +
    ggplot2::facet_wrap(~report_date, scales = "free")

  plot <- plot_CrIs(plot, extract_CrIs(x$obs),
    alpha = 0.8, linewidth = 1
  )

  plot <- plot +
    ggplot2::theme_bw() +
    ggplot2::labs(
      y = "Confirmed Cases", x = "Date", col = "Type", fill = "Type"
    ) +
    ggplot2::scale_x_date(date_breaks = "day", date_labels = "%b %d") +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
  return(plot)
}
