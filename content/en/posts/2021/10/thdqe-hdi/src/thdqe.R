getBetaHdi <- function(a, b, width) {
  eps <- 1e-9
  if (a < 1 + eps & b < 1 + eps) # Degenerate case
    return(c(NA, NA))
  if (a < 1 + eps & b > 1) # Left border case
    return(c(0, width))
  if (a > 1 & b < 1 + eps) # Right border case
    return(c(1 - width, 1))
  if (width > 1 - eps)
    return(0, 1)
  
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

thdquantile <- function(x, probs, width = 1 / sqrt(length)) sapply(probs, function(p) {
  x <- sort(x)
  n <- length(x)
  a <- (n + 1) * p
  b <- (n + 1) * (1 - p)
  hdi <- getBetaHdi(a, b, width)
  hdiCdf <- pbeta(hdi, a, b)
  cdf <- function(xs) sapply(xs, function(x) {
    if (x <= hdi[1])
      return(0)
    if (x >= hdi[2])
      return(1)
    return((pbeta(x, a, b) - hdiCdf[1]) / (hdiCdf[2] - hdiCdf[1]))
  })
  cdfs <- cdf(0:n/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x * W)
})