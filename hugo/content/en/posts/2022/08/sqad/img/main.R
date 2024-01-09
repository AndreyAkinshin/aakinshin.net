# Scripts ----------------------------------------------------------------------
source("utils.R")
source("mad-factors.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  unbiasing = list(
    rebuild = FALSE,
    filename = "data-sqad-factors.csv",
    repetitions = 5 * 1000 * 1000, # 5 * 1000 * 1000 ~ 5.2h
    ns = c(
      3:100,
      c(109, 110) + rep(seq(0, 90, by = 10), each = 2),
      c(249, 250) + rep(seq(0, 250, by = 50), each = 2),
      600, 700, 800, 900, 1000, 1500, 2000, 3000
    ),
    eps = 1e-5
  ),
  eff = list(
    rebuild = FALSE,
    filename = "data-efficiency.csv",
    repetitions = 2 * 1000 * 1000, # 2 * 1000 * 1000 ~ 4.4h
    ns = c(
      3:100,
      c(109, 110) + rep(seq(0, 90, by = 10), each = 2),
      c(249, 250) + rep(seq(0, 250, by = 50), each = 2),
      600, 700, 800, 900, 1000, 1500, 2000, 3000,
      10000, 50000
    )
  )
)

# Functions --------------------------------------------------------------------

qad <- function(x, p) as.numeric(quantile(abs(x - median(x)), p))

reload_sqad_factors <- function() {
  sqad_factors <<- if (file.exists(settings$unbiasing$filename)) read.csv(settings$unbiasing$filename) else data.frame()
}
reload_sqad_factors()
get_approximation_coefficients <- function() {
  df <- sqad_factors
  df <- df[df$n >= 100 & df$n <= 1000, ]
  df$bias <- df$factor - 1
  fit <- lm(bias ~ 0 + I(n^(-1)) + I(n^(-2)), data = df)
  fit$coefficients
}
sqad_factor <- function(n, always_predict = FALSE) {
  if (n %in% sqad_factors$n && !always_predict)
    return(sqad_factors[sqad_factors$n == n, "factor"])
  coef <- get_approximation_coefficients()
  as.numeric(1 + coef[1] / n + coef[2] / n^2)
}
sqad <- function(x, factor = NULL) {
  n <- length(x)
  if (is.null(factor))
    factor <- sqad_factor(n)
  factor * qad(x, 2 * (pnorm(1) - 0.5))
}

c4 <- function(n) ifelse(n < 300, sqrt(2 / (n - 1)) * gamma(n / 2) / gamma((n - 1) / 2), 1)
sd_unbiased <- function(x) sd(x) / c4(length(x))

# Data -------------------------------------------------------------------------

build_sqad_factors <- with_logging(function(rebuild = NULL, filename = NULL, repetitions = NULL, ns = NULL, eps = NULL) {
  apply_settings(settings$unbiasing)

  process <- function(n) {
    factor <- 1 / mean(future_replicate(repetitions, sqad(rnorm(n), 1)))
    data.frame(n = n, factor = round(factor, 5))
  }

  df <- multi_estimate(rebuild, filename, ns, process)
  reload_sqad_factors()
  df
})

build_efficiency <- with_logging(function(rebuild = NULL, filename = NULL, repetitions = NULL, ns = NULL) {
  apply_settings(settings$eff)

  estimate <- function(x) {
    c(
      n = length(x),
      sd = sd_unbiased(x),
      mad = mad.sm(x),
      sqad = sqad(x)
    )
  }

  process <- function(n) {
    df_n <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n)))))

    df <- data.frame(
      n = n,
      bias.sd = mean(df_n$sd),
      bias.mad = mean(df_n$mad),
      bias.sqad = mean(df_n$sqad),
      svar.sd = n * var(df_n$sd) / mean(df_n$sd)^2,
      svar.mad = n * var(df_n$mad) / mean(df_n$mad)^2,
      svar.sqad = n * var(df_n$sqad) / mean(df_n$sqad)^2
    )
    df$eff.mad <- df$svar.sd / df$svar.mad
    df$eff.sqad <- df$svar.sd / df$svar.sqad

    round(df, 5)
  }

  multi_estimate(rebuild, filename, ns, process)
})

# Tables -----------------------------------------------------------------------

table_sqad_factors <- function() {
  reload_sqad_factors()
  kable(sqad_factors)
}

table_efficiency <- function() {
  kable(read.csv(settings$eff$filename))
}

# Figures ----------------------------------------------------------------------

figure_sqad_factors <- function() {
  df <- build_sqad_factors()
  df <- df[df$n <= 100, ]

  ggplot(df, aes(n, factor)) +
    geom_hline(yintercept = 1, linetype = "dashed") +
    geom_point(col = cbp$red) +
    scale_y_continuous(limits = c(1, NA)) +
    labs(title = "SQAD bias-correction factors")
}

figure_sqad_factors2 <- function() {
  df_actual <- build_sqad_factors()
  df_actual <- df_actual[df_actual$n >= 100,]
  df_predicted <- data.frame(n = 100:3000)
  coef <- get_approximation_coefficients()
  df_predicted$factor <- 1 + coef[1] / df_predicted$n + coef[2] / df_predicted$n^2
  df_actual$factor_predicted <- 1 + coef[1] / df_actual$n + coef[2] / df_actual$n^2
  df_actual$diff <- abs(df_actual$factor - df_actual$factor_predicted)
  
  ggplot() +
    geom_line(data = df_predicted, aes(n, factor), col = cbp$grey) +
    geom_point(data = df_actual, aes(n, factor), col = cbp$red) +
    ggtitle("SQAD bias-correction factors: actual and predicted")
}

figure_efficiency <- function(maxn = 1000) {
  df <- build_efficiency() %>% extract_coumns("eff")
  df <- df[df$n <= maxn, ]
  df2 <- df %>% gather("type", "value", -n)
  df2$type <- factor(df2$type, levels = c("mad", "sqad"))

  ggplot(df2, aes(n, value, col = type)) +
    geom_point(size = 1) +
    labs(
      title = "Gaussian efficiency of MAD and SQAD",
      x = "Sample size",
      y = "Relative efficiency",
      col = "Estimator",
      shape = "Parity",
      linetype = "Parity"
    ) +
    scale_color_manual(values = cbp$values, labels = c("MAD", "SQAD"))
}

figure_efficiency100 <- function() figure_efficiency(100)

figure_normal <- function() {
  stat_function_fill <- function(fill, xlim) {
    stat_function(fun = dnorm, geom = "area", fill = fill, alpha = 0.25, xlim = xlim)
  }
  
  geom_vsegm <- function(x0, linetype = "dashed") {
    geom_segment(aes(x = x0, y = 0, xend = x0, yend = dnorm(x0)), linetype = linetype)
  }
  
  ticks <- c(
    TeX("$\\bar{x}-4s$"),
    TeX("$\\bar{x}-3s$"),
    TeX("$\\bar{x}-2s$"),
    TeX("$\\bar{x}-1s$"),
    TeX("$\\bar{x}$"),
    TeX("$\\bar{x}+1s$"),
    TeX("$\\bar{x}+2s$"),
    TeX("$\\bar{x}+3s$"),
    TeX("$\\bar{x}+4s$"))
  
  ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm) +
    stat_function_fill("#E69F00", c(-3, -2)) +
    stat_function_fill("#56B4E9", c(-2, -1)) +
    stat_function_fill("#CC79A7", c(-1, +1)) +
    stat_function_fill("#56B4E9", c(+1, +2)) +
    stat_function_fill("#E69F00", c(+2, +3)) +
    labs(x = "", y = "", title = "Normal Distribution") +
    geom_vsegm(-3) +
    geom_vsegm(-2) +
    geom_vsegm(-1) +
    geom_vsegm(0, "solid") +
    geom_vsegm(1) +
    geom_vsegm(2) +
    geom_vsegm(3) +
    geom_text(x =  0.55, y = 0.180, size = 4.5, label = "34.1%") +
    geom_text(x = -0.55, y = 0.180, size = 4.5, label = "34.1%") +
    geom_text(x =  1.45, y = 0.050, size = 3.8, label = "13.6%") +
    geom_text(x = -1.45, y = 0.050, size = 3.8, label = "13.6%") +
    geom_text(x =  2.3,  y = 0.008, size = 2.9, label =  "2.14%") +
    geom_text(x = -2.3,  y = 0.008, size = 2.9, label =  "2.14%") +
    scale_x_continuous(breaks = c(-4:4), labels = ticks) +
    scale_y_continuous(expand = c(0, 0))
}

# Plotting ---------------------------------------------------------------------
build_sqad_factors()
build_efficiency()
regenerate_figures()
