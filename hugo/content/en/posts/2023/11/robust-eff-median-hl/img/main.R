# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Settings ---------------------------------------------------------------------
SAMPLE_SIZE <- 30
REPITITIONS <- 100000
CACHE_MODE <- TRUE

# Functions --------------------------------------------------------------------
hl <- function(x) {
  walsh <- outer(x, x, "+") / 2
  median(walsh[lower.tri(walsh, diag = TRUE)])
}

# Data -------------------------------------------------------------------------
build_df_single <- function(distribution, rD, n, m = REPITITIONS) {
  pad <- function(estimator) replicate(m, abs(estimator(rD(n)) - estimator(rD(n))))
  
  pad_mean <- pad(mean)
  pad_median <- pad(median)
  pad_hl <- pad(hl)
  
  probs <- seq(0.10, 0.90, by = 0.02)
  get_eff <- function(pad_target) quantile(pad_mean, probs)^2 / quantile(pad_target, probs)^2
  df <- rbind(
    data.frame(probs = probs, eff = get_eff(pad_median), estimator = "median"),
    data.frame(probs = probs, eff = get_eff(pad_hl), estimator = "hl")
  )
  df$n <- n
  df$distribution <- distribution
  df
}
build_df <- function(n = SAMPLE_SIZE) {
  distributions <- list(
    list(title = "Uniform", rD = runif),
    list(title = "Normal", rD = rnorm),
    list(title = "Exp", rD = rexp),
    list(title = "LogNormal", rD = rlnorm),
    list(title = "Weibull(0.5)", rD = function(n) rweibull(n, 0.5)),
    list(title = "Cauchy", rD = rcauchy)
  )
  filename <- "data.csv"
  if (file.exists(filename) && CACHE_MODE)
    df <- read.csv(filename)
  else {
    dfs <- lapply(distributions, function(d) build_df_single(d$title, d$rD, n))
    df <- do.call("rbind", dfs)
    write.csv(df, filename, quote = FALSE, row.names = FALSE)
  }
  
  df$estimator <- factor(df$estimator, levels = c("median", "hl"))
  df$distribution <- factor(df$distribution, levels = sapply(distributions, function(d) d$title))
  df
}
df <- build_df()

# Figures ----------------------------------------------------------------------
figure_eff <- function() {
  estimator_labels <- c("Median", "Hodges-Lehmann")
  ggplot(df, aes(probs, eff, col = estimator, shape = estimator)) +
    facet_wrap(vars(distribution), scales = "free_y", ncol = 3) +
    geom_point() +
    geom_hline(yintercept = 1, col = cbp$pink) +
    scale_x_continuous(breaks = seq(0.1, 0.9, by = 0.1)) +
    scale_y_continuous(limits = c(0, NA)) +
    scale_color_manual(labels = estimator_labels, values = cbp$values) +
    scale_shape_manual(labels = estimator_labels, values = c(16, 17)) +
    theme(
      legend.position = "bottom"
    ) +
    labs(
      x = "Quantile order (pairwise absolute differences)",
      y = "Efficiency",
      col = "Estimator",
      shape = "Estimator",
      title = paste0("Relative efficiency to the mean (n=", SAMPLE_SIZE, ")")
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
