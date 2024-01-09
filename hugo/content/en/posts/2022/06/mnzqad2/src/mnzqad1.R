qad <- function(x, p = 0.5, q = 0.5) as.numeric(quantile(abs(x - quantile(x, p)), q))
mnzqad <- function(x, p = 0.5) {
  n <- length(x)
  anchor <- quantile(x, p)
  k <- sum(abs(x - anchor) < 1e-9)
  q0 <- max(k - 1, 0) / (n - 1)
  qm <- (q0 + 1) / 2
  qad(x, 0.5, qm)
}
rrnorm <- function(n, sd = 1) {
  x <- rnorm(n, sd = sd)
  x[x < 0] <- 0
  x
}
set.seed(1729)
replicate(20, mnzqad(rrnorm(1000)))