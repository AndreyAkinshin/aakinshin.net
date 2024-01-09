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

getBetaHdi <- function(a, b, width) {
  eps <- 1e-9
  if (a < 1 + eps & b < 1 + eps) # Degenerate case
    return(c(NA, NA))
  if (a < 1 + eps & b > 1) # Left border case
    return(c(0, width))
  if (a > 1 & b < 1 + eps) # Right border case
    return(c(1 - width, 1))
  if (width > 1 - eps)
    return(c(0, 1))
  
  # Middle case
  mode <- (a - 1) / (a + b - 2)
  pdf <- function(x) dbeta(x, a, b)
  
  l <- uniroot(
    f = function(x) pdf(x) - pdf(x + width),
    lower = max(0, mode - width),
    upper = min(mode, 1 - width),
    tol = 1e-9
  )$root
  r <- l + width
  return(c(l, r))
}

thdquantile <- function(x, probs, width = 1 / sqrt(length(x))) sapply(probs, function(p) {
  n <- length(x)
  if (n == 0) return(NA)
  if (n == 1) return(x)
  x <- sort(x)
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  hdi <- getBetaHdi(a, b, width)
  hdiCdf <- pbeta(hdi, a, b)
  cdf <- function(xs) {
    xs[xs <= hdi[1]] <- hdi[1]
    xs[xs >= hdi[2]] <- hdi[2]
    (pbeta(xs, a, b) - hdiCdf[1]) / (hdiCdf[2] - hdiCdf[1])
  }
  iL <- floor(hdi[1] * n)
  iR <- ceiling(hdi[2] * n)
  cdfs <- cdf(iL:iR/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x[(iL+1):iR] * W)
})

# Data -------------------------------------------------------------------------
build_df <- function() {
  apply_settings(settings$efficiency)

  estimate <- function(x) c(
    mean = mean(x),
    median = median(x),
    hdmedian = as.numeric(hdquantile(x, 0.5)),
    thdmedian = thdquantile(x, 0.5)
  )
  process <- function(n) {
    df <- data.frame(t(future_replicate(repetitions, estimate(rnorm(n)))))
    data.frame(
      n = n,
      median = var(df$mean) / var(df$median),
      hdmedian = var(df$mean) / var(df$hdmedian),
      thdmedian = var(df$mean) / var(df$thdmedian)
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
  df$metric <- factor(df$metric, levels = c("median", "hdmedian", "thdmedian"))
  ggplot(df, aes(n, value, col = metric)) +
    geom_point() +
    scale_color_manual(values = cbp$values, labels = c("Sample median", "HD median", "THD median")) +
    labs(x = "Sample size (n)", y = "Gaussian efficiency", col = "Median estimator")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
