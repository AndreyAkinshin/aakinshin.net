sv1quantile <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    B(0) * (x[1] + x[2] - x[3]) / 2 +
      sum(sapply(1:n, function(i) (B(i) + B(i - 1)) * x[i] / 2)) +
      B(n) * (-x[n-2] + x[n-1] + x[n]) / 2
  })
}
sv2quantile <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    sum(sapply(1:n, function(i) B(i - 1) * x[i])) + B(n) * (2 * x[n] - x[n - 1])
  })
}
sv3quantile <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    sum(sapply(1:n, function(i) B(i) * x[i])) +
      B(0) * (2 * x[1] - x[2])
  })
}