skip_on_cran()
skip_on_os("windows")

# test primary reports and observations
reports <- rep(10, 20)
obs <- rep(4, 20)
delay_rev_pmf <- rev(discretised_pmf(c(log(3), 0.1), 5, 0))
scaled <- reports * 0.1
convolved <- rep(1e-5, 20) + convolve_to_report(scaled, delay_rev_pmf, 0)

check_equal <- function(args, target, dof = 0, dev = FALSE) {
  out <- do.call(calculate_secondary, args)
  out <- round(out, dof)
  if (dev) {
    return(out)
  }
  expect_equal(out, target)
}

test_that("calculate_secondary can calculate prevalence as expected", {
  check_equal(
    args = list(scaled, convolved, obs, 1, 1, 1, 1, 1, 20),
    target = c(1, 5, 5.3, 5.7, rep(6, 16)), dof = 1
  )
})

test_that("calculate_secondary can calculate incidence as expected", {
  check_equal(
    args = list(scaled, convolved, obs, 0, 1, 1, 1, 1, 20),
    target = c(1, 1, 1.3, 1.7, rep(2.0, 16)), dof = 1
  )
})

test_that("calculate_secondary can calculate incidence as expected", {
  check_equal(
    args = list(scaled, convolved, obs, 0, 1, 1, 1, 1, 20),
    target = c(1, 1, 1.3, 1.7, rep(2.0, 16)), dof = 1
  )
})

test_that("calculate_secondary can calculate incidence using only historic reports", {
  check_equal(
    args = list(scaled, convolved, obs, 0, 1, 1, 0, 1, 20),
    target = c(0, 0, 0, rep(1, 17)), dof = 0
  )
})

test_that("calculate_secondary can calculate incidence using only current reports", {
  check_equal(
    args = list(scaled, convolved, obs, 0, 0, 1, 1, 1, 20),
    target = rep(1, 20), dof = 0
  )
})

test_that("calculate_secondary can switch into prediction mode as expected", {
  check_equal(
    args = list(scaled, convolved, obs, 1, 0, 1, 1, 1, 20),
    target = c(1, rep(5, 19)), dof = 0
  )
  check_equal(
    args = list(scaled, convolved, obs, 1, 0, 1, 1, 1, 10),
    target = c(1, rep(5, 9), 6:15), dof = 0
  )
})
