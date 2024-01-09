library(rootSolve)
options(digits = 15)
f <- function(p) 0.5^exp(-p) - 0.5^exp(p) - 0.5
uniroot.all(f, c(-10, 10), tol = 1e-15)