library(knitr)
options(scipen = 999)

k <- 10
p <- outer(1:k, 1:k, Vectorize(function(n, m) {
 1 / choose(n + m, m)
}))
rownames(p) <- 1:k
colnames(p) <- 1:k
kable(p, row.names = T, digits = 6)