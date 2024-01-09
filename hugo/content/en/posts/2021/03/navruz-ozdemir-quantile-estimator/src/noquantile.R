noquantile <- function(x, probs) {
  n <- length(x)
  if (n <= 2)
    return(quantile(x, probs))
  x <- sort(x)
  sapply(probs, function(p) {
    B <- function(x) dbinom(x, n, p)
    (B(0) * 2 * p + B(1) * p) * x[1] +
      B(0) * (2 - 3 * p) * x[2] -
      B(0) * (1 - p) * x[3] +
      sum(sapply(1:(n-2), function(i)
        (B(i) * (1 - p) + B(i + 1) * p) * x[i + 1])) -
      B(n) * p * x[n - 2] +
      B(n) * (3 * p - 1) * x[n - 1] +
      (B(n - 1) * (1 - p) + B(n) * (2 - 2 * p)) * x[n]
  })
}