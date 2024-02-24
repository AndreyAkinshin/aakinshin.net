mnzqad2 <- function(x, p = 0.5) {
  n <- length(x)
  anchor <- quantile(x, p)
  k <- n - sum(table(x) == 1)
  q0 <- max(k - 1, 0) / (n - 1)
  qm <- (q0 + 1) / 2
  qad(x, 0.5, qm)
}
set.seed(1729)
replicate(20, mnzqad2(rrnorm(1000)))