# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  constants = list(
    rebuild = FALSE,
    filename = "data-consistency-constants.csv",
    repetitions1 = 10 * 1000 * 1000,
    repetitions2 = 1000 * 1000,
    ns = c(
      2:100,
      c(109, 110) + rep(seq(0, 90, by = 10), each = 2),
      c(249, 250) + rep(seq(0, 750, by = 50), each = 2),
      c(1499, 1500) + rep(seq(0, 3500, by = 500), each = 2),
      c(9999, 10000)
    )
  )
)

# Functions --------------------------------------------------------------------

sn_bias_rc <- function(n) sapply(n, function(n) {
  if (n <= 9) {
    c(0.743, 1.851, 0.954, 1.351, 0.993, 1.198, 1.005, 1.131)[n - 1]
  }
  else if (n %% 2) 
    n/(n - 0.9)
  else 1
})

qn_bias_rc <- function(n) sapply(n, function(n) {
  Qn.finite.c <- function(n)
    (if (n %% 2) n / (n + 1.4) # n  odd
     else        n / (n + 3.8) # n  even
    )
  if (n <= 9) 
    c(0.399, 0.994, 0.512, 0.844, 0.611, 0.857, 0.669, 0.872)[n - 1L]
  else Qn.finite.c(n)
})

qn_bias_rb <- function(n) sapply(n, function(n) {
  Qn.finite.c <- function(n)
    (if (n %% 2) 1.60188 + (-2.1284 - 5.172/n)/n # n  odd
     else        3.67561 + ( 1.9654 + (6.987 - 77/n)/n)/n # n  even
    )/n + 1
  if (n <= 12) 
    c(0.399356, 0.99365, 0.51321, 0.84401, 0.6122, 
          0.85877, 0.66993, 0.87344, 0.72014, 0.88906, 
          0.75743)[n - 1L]
  else 1 / Qn.finite.c(n)
})

to_tex <- function(estimator) {
  unname(c("sn" = "$S_n$", "qn" = "$Q_n$")[estimator])
}

asymptotic_sn_constant <- uniroot(
  function(c) pnorm(qnorm(3 / 4) + 1 / c) - pnorm(qnorm(3 / 4) - 1 / c) - 1 / 2,
  c(1.19, 1.20),
  tol = 1e-15
)$root
asymptotic_qn_constant <- 1 / (sqrt(2) * qnorm(5 / 8))
get_asymptotic_constant <- function(estimator) {
  unname(c("sn" = asymptotic_sn_constant, "qn" = asymptotic_qn_constant)[estimator])
}

get_bias_coefficients <- function(estimator, parity) {
  df <- data_full()
  df <- df[df$n >= 100 & df$n <= 1000 & df$n %% 2 == parity, ]
  df$bias <- df[, paste0(estimator, "_factor")] - 1
  fit <- lm(bias ~ 0 + I(n^(-1)) + I(n^(-2)), data = df)
  fit$coefficients
}

get_factor <- function(estimator, ns, always_predict = FALSE) {
  sapply(ns, function(n) {
    df <- data_full()
    if (n %in% df$n && !always_predict) {
      return(df[df$n == n, paste0(estimator, "_factor")])
    }

    coefficients <- get_bias_coefficients(estimator, n %% 2)
    1 + coefficients[1] / n + coefficients[2] / n^2
  })
}

# Data -------------------------------------------------------------------------

simulation_constants <- function(rebuild = NULL, filename = NULL, repetitions = NULL, ns = NULL) {
  apply_settings(settings$constants)

  process <- function(n) {
    repetitions <- if (n <= 100) repetitions1 else repetitions2
    sn_constant <- 1 / mean(future_replicate(repetitions, Sn(rnorm(n), 1)))
    qn_constant <- 1 / mean(future_replicate(repetitions, Qn(rnorm(n), 1)))
    data.frame(
      n = n,
      sn = round(sn_constant, 6),
      qn = round(qn_constant, 6)
    )
  }

  multi_estimate(rebuild, filename, ns, process)
}

data_full <- function() {
  df_constants <- simulation_constants()
  data.frame(
    n = df_constants$n,
    parity = ifelse(df_constants$n %% 2 == 0, "Even", "Odd"),
    sn_constant = df_constants$sn,
    sn_factor = df_constants$sn / asymptotic_sn_constant,
    sn_bias = df_constants$sn / asymptotic_sn_constant - 1,
    qn_constant = df_constants$qn,
    qn_factor = df_constants$qn / asymptotic_qn_constant,
    qn_bias = df_constants$qn / asymptotic_qn_constant - 1
  )
}

data_factor_compare <- function(estimator) {
  df_full <- data_full()
  df <- data.frame(n = df_full$n, new = df_full[, paste0(estimator, "_factor")])
  if (estimator == "sn") {
    df$rc <- sn_bias_rc(df$n)
    df$diff <- abs(df$new - df$rc)
  }
  if (estimator == "qn") {
    df$rc <- qn_bias_rc(df$n)
    df$diff_rc <- abs(df$new - df$rc)
    df$rb <- qn_bias_rb(df$n)
    df$diff_rb <- abs(df$new - df$rb)
  }
  df
}

data_factors <- function(maxn = 100) {
  df_full <- data_full()
  df_full <- df_full[df_full$n <= maxn, ]
  round(data.frame(
    n = df_full$n,
    sn = df_full$sn_factor,
    qn = df_full$qn_factor
  ), 5)
}

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------

helper_figure_bias1 <- function(estimator) {
  df <- data_full()
  df <- df[df$n <= 100, ]
  df$value <- df[, paste0(estimator, "_factor")]

  ggplot(df, aes(n, value, color = parity)) +
    geom_hline(yintercept = 1, linetype = "dashed", col = cbp$grey) +
    geom_point(aes(shape = parity)) +
    labs(
      title = TeX(paste0("Bias-correction factors for ", to_tex(estimator), " ($n \\leq 100$)")),
      x = "Sample size (n)",
      y = "Bias-correction factor",
      col = "Parity",
      shape = "Parity"
    )
}

helper_figure_bias2 <- function(estimator) {
  df <- data_full()
  df <- df[df$n > 100, ]
  df$value <- df[, paste0(estimator, "_factor")]
  df$predicted <- get_factor(estimator, df$n, TRUE)

  ggplot(df, aes(n, value, col = parity, shape = parity)) +
    geom_hline(yintercept = 1, linetype = "dashed", col = cbp$grey) +
    geom_line(aes(n, predicted), alpha = 0.5) +
    geom_point() +
    labs(
      title = TeX(paste0("Bias-correction factors for ", to_tex(estimator), ": actual and predicted (n > 100)")),
      x = "Sample size (n)",
      y = "Bias-correction factor",
      col = "Parity",
      shape = "Parity"
    )
}

figure_bias1_sn <- function() helper_figure_bias1("sn")
figure_bias1_qn <- function() helper_figure_bias1("qn")
figure_bias2_sn <- function() helper_figure_bias2("sn")
figure_bias2_qn <- function() helper_figure_bias2("qn")

# Plotting ---------------------------------------------------------------------
simulation_constants()
regenerate_figures()
