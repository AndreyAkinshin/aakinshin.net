library(evd)
library(EnvStats)
library(stringr)

d.unif <- list(title = "Uniform(a=0, b=1)", r = runif, q = qunif)
d.tri_0_2_1 <- list(title = "Triangular(a=0, b=2, c=1)", r = function(n) rtri(n, 0, 2, 1), q = function(p) qtri(p, 0, 2, 1))
d.tri_0_2_02 <- list(title = "Triangular(a=0, b=2, c=0.2)", r = function(n) rtri(n, 0, 2, 0.2), q = function(p) qtri(p, 0, 2, 0.2))
d.beta2_4 <- list(title = "Beta(a=2, b=4)", r = function(n) rbeta(n, 2, 4), q = function(p) qbeta(p, 2, 4))
d.beta2_10 <- list(title = "Beta(a=2, b=10)", r = function(n) rbeta(n, 2, 10), q = function(p) qbeta(p, 2, 10))

d.norm <- list(title = "Normal(m=0, sd=1)", r = rnorm, q = qnorm)
d.weibull1_2 <- list(title = "Weibull(scale=1, shape=2)", r = function(n) rweibull(n, 2), q = function(p) qweibull(p, 2))
d.student3 <- list(title = "Student(df=3)", r = function(n) rt(n, 3), q = function(p) qt(p, 3))
d.gumbel <- list(title = "Gumbel(loc=0, scale=1)", r = rgumbel, q = qgumbel)
d.exp <- list(title = "Exp(rate=1)", r = rexp, q = qexp)

d.cauchy <- list(title = "Cauchy(x0=0, gamma=1)", r = rcauchy, q = qcauchy)
d.pareto1_05 <- list(title = "Pareto(loc=1, shape=0.5)", r = function(n) rpareto(n, 1, 0.5), q = function(p) qpareto(p, 1, 0.5))
d.pareto1_2 <- list(title = "Pareto(loc=1, shape=2)", r = function(n) rpareto(n, 1, 2), q = function(p) qpareto(p, 1, 2))
d.lnorm0_1 <- list(title = "LogNormal(mlog=0, sdlog=1)", r = function(n) rlnorm(n, 0, 1), q = function(p) qlnorm(p, 0, 1))
d.lnorm0_2 <- list(title = "LogNormal(mlog=0, sdlog=2)", r = function(n) rlnorm(n, 0, 2), q = function(p) qlnorm(p, 0, 2))

d.lnorm0_3 <- list(title = "LogNormal(mlog=0, sdlog=3)", r = function(n) rlnorm(n, 0, 3), q = function(p) qlnorm(p, 0, 3))
d.weibull1_03 <- list(title = "Weibull(shape=0.3)", r = function(n) rweibull(n, 0.3), q = function(p) qweibull(p, 0.3))
d.weibull1_05 <- list(title = "Weibull(shape=0.5)", r = function(n) rweibull(n, 0.5), q = function(p) qweibull(p, 0.5))
d.frechet1 <- list(title = "Frechet(shape=1)", r = function(n) rfrechet(n, shape = 1), q = function(p) qfrechet(p, shape = 1))
d.frechet3 <- list(title = "Frechet(shape=3)", r = function(n) rfrechet(n, shape = 3), q = function(p) qfrechet(p, shape = 3))

ds <- list(
  d.unif, d.tri_0_2_1, d.tri_0_2_02, d.beta2_4, d.beta2_10,
  d.norm, d.weibull1_2, d.student3, d.gumbel, d.exp,
  d.cauchy, d.pareto1_05, d.pareto1_2, d.lnorm0_1, d.lnorm0_2,
  d.lnorm0_3, d.weibull1_03, d.weibull1_05, d.frechet1, d.frechet3
)

hls <- function(x, y, alpha = 0.95) {
  df <- expand.grid(x = x, y = y)
  d <- sort(df$y - df$x)
  shift <- mean(d)
  n <- length(x)
  m <- length(y)
  A <- n * m / 2 - 0.5
  z <- qnorm((1 + alpha) / 2)
  B <- z * sqrt(n * m * (n + m + 1) / 12)
  l <- max(round(A - B), 1)
  r <- min(round(A + B), length(d))
  list(shift = shift, l = d[l], r = d[r])
}
coverage <- function(rdist, n, true.shift, alpha = 0.95, iterations = 10000) {
  cover.cnt <- 0
  for (iter in 1:iterations) {
    est <- hls(rdist(10), rdist(10) + true.shift, alpha)
    if (est$l < true.shift && true.shift < est$r)
      cover.cnt <- cover.cnt + 1
  }
  cover.cnt / iterations
}

for (n in c(5, 10, 50))
  for (alpha in c(0.90, 0.95, 0.99)) {
    cat(paste0("*** n = ", n, ", alpha = ", alpha * 100, "% ***\n"))
    for (d in ds) {
      c <- coverage(d$r, n, 5, alpha) * 100
      cat(paste0(str_pad(d$title, 30, "right"), ": ", str_pad(format(c, nsmall = 2), 6, "left"), "%\n"))
    }
    cat("\n")
  }