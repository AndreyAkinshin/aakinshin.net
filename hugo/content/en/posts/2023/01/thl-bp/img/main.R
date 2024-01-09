# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------
hl <- function(x) {
  n <- length(x)
  ind <- expand.grid(i = 1:n, j = 1:n) %>% filter(i < j)
  median(x[ind$i] + x[ind$j]) / 2
}
thl <- function(x, k) {
  n <- length(x)
  x <- sort(x)
  r <- (k + 1):(n - k)
  ind <- expand.grid(i = r, j = r) %>% filter(i < j)
  if (nrow(ind) == 0)
    median(x)
  else
    median(x[ind$i] + x[ind$j]) / 2
}
hl_bp <- function(n) {
  1 - 1 / (2 * n) - sqrt(1 / 2 - 1 / (2 * n) + 1 / (4 * n^2))
}
hl_ps <- function(n) {
  n - 1 / 2 - sqrt(n^2 / 2 - n / 2 + 1 / 4)
}
thl_ps <- function(n, k) {
  k + hl_ps(n - 2 * k)
}
thl_bp <- function(n, k) thl_ps(n, k) / n
thl_abp <- function(s) {
  (sqrt(2) - 1) * (s + 1 / sqrt(2))
}

cont <- function(p) c(rnorm(n - p), rep(1e100, p))
pr <- function(message, cond1, cond2) {
  cat(paste0(message, ": ", cond1, " / ", cond2, "\n"))
}
check_hl <- function() {
  for (n in 3:50) {
    ps <- hl_ps(n)
    pR <- ceil(ps)
    pL <- pR - 1
    pr(paste0("n=", n), hl(cont(pL)) < 100, hl(cont(pR)) > 100)
  }
}
check_thl <- function() {
  for (n in 3:20) {
    k_max <- (n - 1) %/% 2
    for (k in 0:k_max) {
      ps <- thl_ps(n, k)
      pR <- ceil(ps)
      pL <- pR - 1
      if (n == 2 * k + 1) { # Special case
        pR <- ps + 1
        pL <- ps
      }
      pr(paste0("n=", n, ";k=", k), thl(cont(pL), k) < 100, thl(cont(pR), k) > 100)
    }
  }
}

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
figure_thl_abp <- function() {
  s <- seq(0, 0.5, by = 0.01)
  abp <- sapply(s, function(s) thl_abp(s))
  df <- data.frame(s, abp)
  ggplot(df, aes(s, abp)) +
    geom_line() +
    labs(y = "Asymptotic breakdown point")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
