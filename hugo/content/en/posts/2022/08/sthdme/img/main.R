# Scripts ----------------------------------------------------------------------
source("utils.R")
source("mad-factors.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  efficiency = list(
    rebuild = FALSE,
    filename = "data-factors.csv",
    repetitions = 1000 * 1000,
    ns = c(
      3:100,
      seq(200, 1000, by = 100),
      seq(2000, 10000, by = 1000),
      100000
    )
  )
)

# Functions --------------------------------------------------------------------
sthdm <- function(x) quantile.thd(x, 0.5, pnorm(1) - pnorm(-1))

# Data -------------------------------------------------------------------------

build_efficiency <- function(rebuild = NULL, filename = NULL, repetitions = NULL, ns = NULL) {
  apply_settings(settings$efficiency)

  estimate <- function(x) {
    c(
      mean = mean(x),
      median = median(x),
      sthdm = sthdm(x)
    )
  }

  process <- function(n) {
    df0 <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n)))))

    df <- data.frame(
      n = n,
      median = var(df0$mean) / var(df0$median),
      sthdm = var(df0$mean) / var(df0$sthdm)
    )

    round(df, 5)
  }

  multi_estimate(rebuild, filename, ns, process)
}

# Tables -----------------------------------------------------------------------
table_efficiency <- function() {
  kable(build_efficiency())
}

# Figures ----------------------------------------------------------------------
figure_efficiency100 <- function() {
  df <- build_efficiency() %>% gather("estimator", "value", -n)
  df <- df[df$n <= 100, ]
  df$estimator <- factor(df$estimator, levels = c("median", "sthdm"))
  df$parity <- factor(ifelse(df$n %% 2 == 0, "Even", "Odd"), levels = c("Even", "Odd"))

  ggplot(df, aes(n, value, col = estimator, shape = parity)) +
    geom_line(alpha = 0.3) +
    geom_point() +
    scale_y_continuous(limits = c(0, 1)) +
    scale_color_manual(values = cbp$values, labels = c("Sample\nmedian", "STHDM")) +
    labs(
      title = "Gaussian efficiency of mean estimators",
      col = "Estimator", shape = "Parity", linetype = "Estimator",
      y = "Gaussian efficiency"
    )
}

figure_efficiency <- function() {
  df <- build_efficiency() %>% gather("estimator", "value", -n)
  df$estimator <- factor(df$estimator, levels = c("median", "sthdm"))

  ggplot(df, aes(n, value, col = estimator)) +
    geom_line() +
    scale_y_continuous(limits = c(0, 1)) +
    scale_color_manual(values = cbp$values, labels = c("Sample\nmedian", "STHDM")) +
    labs(
      title = "Gaussian efficiency of mean estimators",
      col = "Estimator", shape = "Parity", linetype = "Estimator",
      y = "Gaussian efficiency"
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
