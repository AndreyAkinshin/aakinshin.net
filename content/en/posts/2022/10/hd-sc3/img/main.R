# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

hdm <- function(x) as.numeric(hdquantile(x, 0.5))

sc <- function(n = 10, qD, title) {
  Tn <- hdm
  X <- qD(1:n / (n + 1))
  limit <- 100
  x <- seq(-limit, limit, length.out = 1001)
  y <- sapply(x, function(x0) (Tn(c(X, x0)) - Tn(X)) * (n + 1))
  data.frame(x, y, n = n, title)
}

sc2 <- function(qD, title, group) {
  ns <- c()
  if (group == 1)
    ns <- 2:5
  if (group == 2)
    ns <- 6:10
  if (group == 3)
    ns <- c(10, 15, 20, 25, 30)
  df <- do.call("rbind", lapply(ns, function(n) sc(n, qD, title)))
  df$group <- group
  df
}

sc3 <- function(qD, title) {
  rbind(sc2(qD, title, 1), sc2(qD, title, 2), sc2(qD, title, 3))
}

# Data -------------------------------------------------------------------------

build_df <- function(group) {
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
  df <- do.call("rbind", lapply(ds, function(d) sc2(d$q, d$title, group)))
}


# Figures ----------------------------------------------------------------------

helper_figure_sc <- function(group) {
  df <- build_df(group)
  df$n <- factor(df$n)
  ggplot(df, aes(x, y, col = n, group = n)) +
    geom_line() +
    facet_wrap(vars(title)) +
    ggtitle("Sensitivity curves")
}

figure_sc1 <- function() helper_figure_sc(1)
figure_sc2 <- function() helper_figure_sc(2)
figure_sc3 <- function() helper_figure_sc(3)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
