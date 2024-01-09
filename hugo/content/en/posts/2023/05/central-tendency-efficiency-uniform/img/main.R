# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
rep <- 100000

# Functions --------------------------------------------------------------------
hl <- function(x) {
  walsh <- outer(x, x, "+") / 2
  median(walsh[lower.tri(walsh, diag = TRUE)])
}
midrange <- function(x) mean(range(x))
rd <- function(n) runif(n)
mse <- function(Tn, n) var(replicate(rep, Tn(rd(n))))
eff_all <- function(n) {
  mean <- mse(mean, n)
  median <- mse(median, n)
  hl <- mse(hl, n)
  midrange <- mse(midrange, n)
  c(
    n = n,
    median = mean / median,
    hl = mean  / hl,
    midrange = mean / midrange
  )
}
samping_distribution <- function(n) {
  replicate(rep, {
    x <- rd(n)
    c(
      n = n,
      mean = mean(x),
      median = median(x),
      hl = hl(x),
      midrange = midrange(x)
    )
  }) %>% t() %>% data.frame()
}

# Data -------------------------------------------------------------------------
df_eff <- data.frame(do.call("rbind", lapply(3:30, function(n) eff_all(n))))
df_samp <- data.frame(do.call("rbind", lapply(c(5, 10, 30), function(n) samping_distribution(n))))

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
figure_eff <- function() {
  df <- df_eff %>% gather("estimator", "eff", -n)
  df$estimator <- factor(df$estimator, levels = c("median", "hl", "midrange"))
  ggplot(df, aes(n, eff, col = estimator)) +
    geom_point() +
    geom_line() +
    scale_color_manual(
      values = cbp$values,
      labels = c("Median", "Hodges-Lehmann", "Midrange")
    ) +
    scale_y_continuous(limits = c(0, NA), breaks = seq(0, max(df$eff + 0.25), by = 0.25)) +
    scale_x_continuous(breaks = unique(df$n)) +
    geom_hline(yintercept = 1, col = cbp$grey) +
    labs(
      title = "Relative efficiency to the mean under the uniform distribution",
      x = "n",
      y = "Efficiency",
      col = "Estimator"
    )
}
draw_samp <- function(n) {
  df <- df_samp[df_samp$n == n,] %>% gather("estimator", "value", -n)
  df$estimator <- factor(df$estimator, levels = c("median", "hl", "midrange", "mean"))
  ggplot(df, aes(value, col = estimator)) +
    geom_density(bw = "SJ") +
    scale_color_manual(
      values = cbp$values,
      labels = c("Median", "Hodges-Lehmann", "Midrange", "Mean")
    ) +
    scale_x_continuous(limits = c(0, 1)) +
    labs(
      title = paste0("Sampling distributions under the uniform distribution (n=", n, ")"),
      x = "Estimation",
      y = "Density",
      col = "Estimator"
    )
}
figure_samp_5 <- function() draw_samp(5)
figure_samp_10 <- function() draw_samp(10)
figure_samp_30 <- function() draw_samp(30)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
