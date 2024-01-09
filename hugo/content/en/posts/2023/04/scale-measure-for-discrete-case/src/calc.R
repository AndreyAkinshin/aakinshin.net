library(effsize)

pooled <- function(x, y, FUN) {
  nx <- length(x)
  ny <- length(y)
  sqrt(((nx - 1) * FUN(x) ^ 2 + (ny - 1) * FUN(y) ^ 2) / (nx + ny - 2))
}
psd <- function(x, y) pooled(x, y, sd)
my.cohen.d <- function(x, y) (mean(x) - mean(y)) / psd(x, y)

psd2 <- function(x, y, delta) sqrt(psd(x, y)^2 + delta^2)
my.cohen.d2 <- function(x, y, delta) (mean(x) - mean(y)) / psd2(x, y, delta)


set.seed(132)
x <- round(rnorm(10), 3)
y <- round(rnorm(10, 1), 3)
dput(x)
dput(y)
dput(round(cohen.d(y, x)$estimate, 3))

dput(round(my.cohen.d(y, x), 9))
dput(round(psd(x, y), 9))

dput(round(my.cohen.d2(y, x, 0.001), 9))
dput(round(psd2(x, y, 0.001), 9))
