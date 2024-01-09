# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  efficiency = list(
    rebuild = FALSE,
    filename = "data-efficiency.csv",
    repetitions = 1000 * 100,
    ns = c(3:100)
  )
)

# Functions --------------------------------------------------------------------
d0 <- function(x, y) mean(y) - mean(x)
dms <- function(x, y) median(y) - median(x)
dhl <- function(x, y) median((expand.grid(x = x, y = y) %>% mutate(d = y - x))$d)

# Data -------------------------------------------------------------------------
build_df <- function() {
  apply_settings(settings$efficiency)
  
  estimate <- function(x, y) c(
    d0 = d0(x, y),
    dms = dms(x, y),
    dhl = dhl(x, y)
  )
  process <- function(n) {
    df <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n), rnorm(n)))))
    data.frame(
      n = n,
      dms = var(df$d0) / var(df$dms),
      dhl = var(df$d0) / var(df$dhl)
    )
  }

  df <- multi_estimate(rebuild, filename, ns, process)
  df
}

# Figures ----------------------------------------------------------------------

figure_efficiency <- function() {
  df <- build_df() %>% gather("metric", "value", -n)
  df <- df[df$n <= 100, ]
  df$metric <- factor(df$metric, levels = c("dms", "dhl"))
  ggplot(df, aes(n, value, col = metric)) +
    geom_point() +
    scale_color_manual(values = cbp$values, labels = c("Shift of the medians", "Hodges-Lehmann")) +
    labs(x = "Sample size (n)", y = "Gaussian efficiency", col = "Estimator")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
