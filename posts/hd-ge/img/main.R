# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  efficiency = list(
    rebuild = FALSE,
    filename = "data-efficiency.csv",
    repetitions = 1000 * 1000,
    ns = c(3:100, 1000, 10000)
  )
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------
build_df <- function() {
  apply_settings(settings$efficiency)

  estimate <- function(x) c(
    mean = mean(x),
    median = median(x),
    hdmedian = as.numeric(hdquantile(x, 0.5))
  )
  process <- function(n) {
    df <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n)))))
    data.frame(
      n = n,
      median = var(df$mean) / var(df$median),
      hdmedian = var(df$mean) / var(df$hdmedian)
    )
  }
  
  df <- multi_estimate(rebuild, filename, ns, process)
  df
}

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
figure_efficiency <- function() {
  df <- build_df() %>% gather("metric", "value", -n)
  df <- df[df$n <= 100, ]
  df$metric <- factor(df$metric, levels = c("median", "hdmedian"))
  ggplot(df, aes(n, value, col = metric)) +
    geom_point() +
    scale_color_manual(values = cbp$values, labels = c("Sample median", "HD median")) +
    labs(x = "Sample size (n)", y = "Gaussian efficiency", col = "Median estimator")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
