library(knitr)
library(evd)
options(scipen=999)
rm(list = ls())

sf <- function(qdist, p, k) {
  q <- qdist(c(p, 0.5, 1 - p))
  l <- q[1] - k * (q[3] - q[1])
  r <- q[3] + k * (q[3] - q[1])
  c(l, r)
}
af <- function(qdist, p, k) {
  q <- qdist(c(p, 0.5, 1 - p))
  l <- q[1] - 2 * k * (q[2] - q[1])
  r <- q[3] + 2 * k * (q[3] - q[2])
  c(l, r)
}

check <- function(fence, p, k, qdist, cdf) {
  s <- cdf(fence(qdist, p, k))
  s[1] + (1 - s[2])
}
run1 <- function(qdist, cdf) {
  ks <- seq(1, 4, by = 0.5)
  ps <- c(0.1, 0.25)
  df <- data.frame()
  for (p in ps)
    for (k in ks) {
      x1 <- check(sf, p, k, qdist, cdf)
      x2 <- check(af, p, k, qdist, cdf)
      df <- rbind(
        df,
        data.frame(type = "SF", p = p, k = k, outliers = x1),
        data.frame(type = "AF", p = p, k = k, outliers = x2)
        )
    }
  df[order(df$type),]
}
run2 <- function(fence, p, qdist, cdf) {
  ns <- c(5, 10, 50, 100, 500, 1000)
  ks <- seq(1, 4, by = 0.5)
  df <- data.frame(outer(ks, ns, Vectorize(function(k, n) {
    x <- check(fence, p, k, qdist, cdf)
    1-(1 - x)^n
  })))
  row.names(df) <- ks
  colnames(df) <- ns
  df
}

kable(run1(qnorm, pnorm), digits = 20, row.names = F)
kable(run1(qexp, pexp), digits = 20, row.names = F)
kable(run1(qgumbel, pgumbel), digits = 20, row.names = F)

kable(run2(sf, 0.1, qnorm, pnorm), digits = 5)
kable(run2(sf, 0.25, qnorm, pnorm), digits = 5)
kable(run2(af, 0.1, qnorm, pnorm), digits = 5)
kable(run2(af, 0.25, qnorm, pnorm), digits = 5)

kable(run2(sf, 0.1, qexp, pexp), digits = 5)
kable(run2(sf, 0.25, qexp, pexp), digits = 5)
kable(run2(af, 0.1, qexp, pexp), digits = 5)
kable(run2(af, 0.25, qexp, pexp), digits = 5)

kable(run2(sf, 0.1, qgumbel, pgumbel), digits = 5)
kable(run2(sf, 0.25, qgumbel, pgumbel), digits = 5)
kable(run2(af, 0.1, qgumbel, pgumbel), digits = 5)
kable(run2(af, 0.25, qgumbel, pgumbel), digits = 5)
