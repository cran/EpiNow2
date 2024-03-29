generation_time <- get_generation_time(disease = "SARS-CoV-2", source = "ganyani", max_value = 5)
reporting_delay <- dist_spec(
  mean = log(3), mean_sd = 0.1,
  sd = log(2), sd_sd = 0.1, max = 5
)

futile.logger::flog.threshold("FATAL")
# uses example case vector
cases <- EpiNow2::example_confirmed[1:30]
cases <- data.table::rbindlist(list(
  data.table::copy(cases)[, region := "testland"],
  cases[, region := "realland"]
))

df_non_zero <- function(df) {
  expect_true(nrow(df) > 0)
}

out <- suppressWarnings(regional_epinow(
  reported_cases = cases,
  generation_time = generation_time_opts(generation_time),
  delays = delay_opts(reporting_delay),
  stan = stan_opts(
    samples = 25, warmup = 25,
    chains = 2,
    control = list(adapt_delta = 0.8)
  ),
  logs = NULL
))

test_that("regional_runtimes produces expected output when with input", {
  skip_on_cran()
  runtimes <- regional_runtimes(out$regional)
  expect_equal(names(runtimes), c("region", "time"))
  df_non_zero(runtimes)
  expect_type(runtimes$time, "double")
})
