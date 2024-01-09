# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
kish_ess <- function(w) sum(w)^2 / sum(w^2)

# Weighted generic quantile estimator
wquantile_generic <- function(x, w, probs, cdf) {
  n <- length(x)
  if (is.null(w)) {
    w <- rep(1 / n, n)
  }
  if (any(is.na(x))) {
    w <- w[!is.na(x)]
    x <- x[!is.na(x)]
  }
  
  nw <- kish_ess(w)
  
  indexes <- order(x)
  x <- x[indexes]
  w <- w[indexes]
  
  w <- w / sum(w)
  t <- cumsum(c(0, w))
  
  sapply(probs, function(p) {
    cdf_values <- cdf(nw, p, t)
    W <- tail(cdf_values, -1) - head(cdf_values, -1)
    sum(W * x)
  })
}

# Weighted traditional quantile estimator
wquantile <- function(x, w, probs, type = 7) {
  if (!(type %in% 4:9)) {
    stop(paste("Unsupported type:", type))
  }
  cdf <- function(n, p, t) {
    h <- switch(type - 3,
                n * p,                   # Type 4
                n * p + 0.5,             # Type 5
                (n + 1) * p,             # Type 6
                (n - 1) * p + 1,         # Type 7
                (n + 1 / 3) * p + 1 / 3, # Type 8
                (n + 1 / 4) * p + 3 / 8  # Type 9
    )
    h <- max(min(h, n), 1)
    pmax(0, pmin(1, t * n - h + 1))
  }
  wquantile_generic(x, w, probs, cdf)
}

wmedian <- function(x, w) wquantile(x, w, 0.5)
hl <- function(x) {
  walsh <- outer(x, x, "+") / 2
  index <- lower.tri(walsh, diag = TRUE)
  median(walsh[index])
}
whl <- function(x, w = NA) {
  if (any(is.na(w)))
    w <- rep(1, length(x))
  walsh_x <- outer(x, x, "+") / 2
  walsh_w <- outer(w, w, "*")
  index <- lower.tri(walsh_x, diag = TRUE)
  wmedian(walsh_x[index], walsh_w[index])
}

# Figures ----------------------------------------------------------------------
figure_sim <- function() {
  mu1 <- 0
  mu2 <- 10
  n <- 10
  w1 <- 1
  w2 <- 2
  gen_hl <- function() {
    x <- ifelse(sample(1:(w1 + w2), n, TRUE) <= w1, rnorm(n, mu1), rnorm(n, mu2))
    hl(x)
  }
  gen_whl <- function() {
    x <- c(rnorm(n / 2, mu1), rnorm(n / 2, mu2))
    w <- c(rep(w1, n / 2), rep(w2, n / 2))
    whl(x, w)
  }
  m <- 1000
  set.seed(1729)
  df <- data.frame(
    hl = replicate(m, gen_hl()),
    whl = replicate(m, gen_whl())
  )
  df <- df %>% gather("estimator", "value")
  df$estimator <- factor(df$estimator, levels = c("hl", "whl"))
  ggplot(df, aes(value, col = estimator)) +
    geom_density(bw = "SJ") +
    scale_color_manual(values = cbp$values, labels = c("HL", "WHL")) +
    labs(
      title = "Sampling distributions",
      x = "Estimation",
      y = "Density",
      col = "Estimator"
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
