library(Hmisc)
library(evd)
library(tidyr)
library(EnvStats)

# Estimating confidence interval using the Maritz-Jarrett method
mj <- function(x, p, alpha) {
  x <- sort(x)
  n <- length(x)
  a <- p * (n + 1)
  b <- (1 - p) * (n + 1)
  cdfs <- pbeta(0:n/n, a, b)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  c1 <- sum(W * x)
  c2 <- sum(W * x^2)
  se <- sqrt(c2 - c1^2)
  estimation <- c1
  margin <- se * qt(1 - (1 - alpha) / 2, df = n - 1)
  c(estimation - margin, estimation + margin)
}

# Estimating confidence interval using the jackknife approach
jk <- function(x, p, alpha) {
  n <- length(x)
  h <- hdquantile(x, p, se = T)
  estimation <- as.numeric(h)
  se <- attr(hdquantile(x, p, se = T), "se")
  margin <- se * qt(1 - (1 - alpha) / 2, df = n - 1)
  c(estimation - margin, estimation + margin)
}

check <- function(name, rfunc, qfunc, prob, alpha, iterations = 10000) {
  true.value <- qfunc(prob)
  mj.score <- 0
  jk.score <- 0
  for (i in 1:iterations) {
    x <- rfunc()
    ci.mj <- mj(x, prob, alpha)
    ci.jk <- jk(x, prob, alpha)
    if (ci.mj[1] < true.value && true.value < ci.mj[2])
      mj.score <- mj.score + 1
    if (ci.jk[1] < true.value && true.value < ci.jk[2])
      jk.score <- jk.score + 1
  }
  mj.score <- mj.score / iterations
  jk.score <- jk.score / iterations
  data.frame(
    name = name,
    n = length(rfunc()),
    "MaritzJarrett" = mj.score,
    "Jackknife" = jk.score)
}
check.single <- function(prob, alpha, n) rbind(
  check("beta(2,10)", function() rbeta(n, 2, 10), function(p) qbeta(p, 2, 10), prob, alpha),
  check("uniform(0,1)", function() runif(n), qunif, prob, alpha),
  check("normal(0,1)", function() rnorm(n), qnorm, prob, alpha),
  check("weibull(1,2)", function() rweibull(n, 2), function(p) qweibull(p, 2), prob, alpha),
  check("gumbel", function() rgumbel(n), qgumbel, prob, alpha),
  check("cauchy", function() rcauchy(n), qcauchy, prob, alpha),
  check("pareto(1,0.5)", function() rpareto(n, 1, 0.5), function(p) qpareto(p, 1, 0.5), prob, alpha),
  check("log-norm(0,3)", function() rlnorm(n, sdlog = 3), qlnorm, prob, alpha)
)
check.all <- function(prob, alpha, ns = 3:50) {
  do.call("rbind", lapply(ns, function(n) check.single(prob, alpha, n)))
}
