# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
hl <- function(x, y = NULL) {
  if (is.null(y)) {
    walsh <- outer(x, x, "+") / 2
    median(walsh[lower.tri(walsh, diag = TRUE)])
  } else {
    median(outer(x, y, "-"))
  }
}

build_df_sampling <- function(rD, n = 10, m = 100000) {
  estimate <- function() {
    x <- rD(n)
    c(mean = mean(x), median = median(x), hl = hl(x))
  }
  df <- data.frame(t(future_replicate(m, estimate()))) %>% gather("measure", "value")
  df$measure <- factor(df$measure, levels = c("mean", "median", "hl"))
  df$n <- n
  df
}
build_df_eff <- function(rD, hint, ns = 3:100) {
  process <- function(n) {
    df_sampling <- build_df_sampling(rD, n)
    var_mean <- var((df_sampling %>% filter(measure == "mean"))$value)
    var_median <- var((df_sampling %>% filter(measure == "median"))$value)
    var_hl <- var((df_sampling %>% filter(measure == "hl"))$value)
    data.frame(n = n, median = var_mean / var_median, hl = var_mean / var_hl)
  }
  filename <- paste0("df_eff_", hint, ".csv")
  df <- multi_estimate(FALSE, filename, ns, process)
  df <- df %>% gather("measure", "eff", -n)
  df
}

draw_sampling <- function(df_sampling, hint, show_hl) {
  if (!show_hl)
    df_sampling <- df_sampling[df_sampling$measure != "hl", ]
  n <- first(df_sampling$n)
  ggplot(df_sampling, aes(value, col = measure)) +
    geom_density(bw = "SJ") +
    scale_color_manual(values = cbp$values) +
    labs(
      title = paste0("Sampling distribution (", hint, ", n = ", n, ")"),
      x = "Estimation",
      y = "Density",
      col = "Measure"
    )
}
draw_eff <- function(df_eff, hint, show_hl) {
  if (!show_hl)
    df_eff <- df_eff[df_eff$measure != "hl", ]
  df_eff$measure <- factor(df_eff$measure, levels = c("mean", "median", "hl"))
  ggplot(df_eff, aes(n, eff, col = measure)) +
    geom_line() +
    geom_point() +
    scale_color_manual(values = cbp$values) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.1)) +
    labs(
      title = paste0("Relative statistical efficiency to the mean (", hint, " distribution)"),
      x = "N (Sample size)",
      y = "Statistical efficiency",
      col = "Measure"
    )
}

# Data -------------------------------------------------------------------------
df_sampling_norm <- build_df_sampling(rnorm)
df_sampling_unif <- build_df_sampling(runif)
df_eff_norm <- build_df_eff(rnorm, "norm")
df_eff_unif <- build_df_eff(runif, "unif")

# Figures ----------------------------------------------------------------------
figure_sampling_norm1 <- function() draw_sampling(df_sampling_norm, "Gaussian", FALSE)
figure_sampling_norm2 <- function() draw_sampling(df_sampling_norm, "Gaussian", TRUE)
figure_sampling_unif1 <- function() draw_sampling(df_sampling_unif, "Uniform", FALSE)
figure_sampling_unif2 <- function() draw_sampling(df_sampling_unif, "Uniform", TRUE)
figure_eff_norm1 <- function() draw_eff(df_eff_norm, "Gaussian", FALSE)
figure_eff_norm2 <- function() draw_eff(df_eff_norm, "Gaussian", TRUE)
figure_eff_unif1 <- function() draw_eff(df_eff_norm, "Uniform", FALSE)
figure_eff_unif2 <- function() draw_eff(df_eff_norm, "Uniform", TRUE)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
