# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  efficiency = list(
    rebuild = FALSE,
    filename = "data-efficiency.csv",
    repetitions = 500 * 1000,
    ns = c(3:50)
  )
)

# Functions --------------------------------------------------------------------
hl <- function(x, y = NULL) {
  if (is.null(y)) {
    walsh <- outer(x, x, "+") / 2
    median(walsh[lower.tri(walsh, diag = TRUE)])
  } else {
    median(outer(x, y, "-"))
  }
}

dmean <- function(x, y) mean(x) - mean(y)
dhl <- function(x, y) hl(x) - hl(y)

# Data -------------------------------------------------------------------------
build_df <- function() {
  apply_settings(settings$efficiency)
  
  estimate <- function(x, y) c(
    dmean = dmean(x, y),
    dhl = dhl(x, y),
    hl = hl(x, y)
  )
  process <- function(n) {
    df <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n), rnorm(n)))))
    data.frame(
      n = n,
      dhl = var(df$dmean) / var(df$dhl),
      hl = var(df$dmean) / var(df$hl)
    )
  }

  df <- multi_estimate(rebuild, filename, ns, process)
  df
}

# Figures ----------------------------------------------------------------------

figure_efficiency <- function() {
  df <- build_df() %>% gather("metric", "value", -n)
  df <- df[df$n <= 100, ]
  df$metric <- factor(df$metric, levels = c("dhl", "hl"))
  ggplot(df, aes(n, value, col = metric)) +
    geom_point() +
    geom_line() +
    scale_x_continuous(breaks = seq(5, 50, by = 5)) +
    scale_color_manual(values = cbp$values, labels = c("Shift of HL", "HL shift")) +
    labs(x = "Sample size (n=m)", y = "Gaussian efficiency", col = "Estimator")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
