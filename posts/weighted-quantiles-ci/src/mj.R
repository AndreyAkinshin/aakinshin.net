mj <- function(x, weights, p, alpha) {
  if (any(is.na(weights)))
    weights <- rep(1 / length(x), length(x))
  
  indexes <- order(x)
  x <- x[indexes]
  weights <- weights[indexes]

  nw <- sum(weights) / max(weights)
  a <- p * (nw + 1)
  b <- (1 - p) * (nw + 1)
  
  cdfs.probs <- cumsum(c(0, weights / sum(weights)))
  cdfs <- pbeta(cdfs.probs, a, b)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  
  c1 <- sum(W * x)
  c2 <- sum(W * x^2)
  se <- sqrt(c2 - c1^2)
  estimation <- c1
  margin <- se * qt(1 - (1 - alpha) / 2, df = nw - 1)

  c(estimation - margin, estimation + margin)
}