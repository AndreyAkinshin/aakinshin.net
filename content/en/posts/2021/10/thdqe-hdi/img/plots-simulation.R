library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(dplyr)
library(latex2exp)
library(knitr)
library(stringr)
library(jsonlite)
library(EnvStats)
library(evd)
require(compiler)

rm(list = ls())
enableJIT(3)

### Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 900 / dpi
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

source("../src/thdqe.R")

# Contaminated normal distribution
rcnorm <- function(n, mean = 0, sd = 1, eps = 0.01, c = 1000000)
  ifelse(runif(n) > eps, rnorm(n, mean, sd), rnorm(n, mean, sd * sqrt(c)))

# Quantile estimators
hf7qe <- function(x, probs) as.numeric(quantile(x, probs))
hdqe <- function(x, probs) as.numeric(hdquantile(x, probs))
thdqe <- function(x, probs) as.numeric(thdquantile(x, probs))

# Simulation #1
simulation1 <- function() {
  gen <- function() {
    x <- rcnorm(7)
    c(
      hf7 = hf7qe(x, 0.5),
      hd = hdqe(x, 0.5),
      thd = thdqe(x, 0.5))
  }
  set.seed(1729)
  df.raw <- data.frame(t(replicate(10000, gen())))
  probs <- c(seq(0, 0.05, by = 0.01), seq(0.95, 1, by = 0.01))
  df <- data.frame(
    quantile = probs,
    HF7 = quantile(df.raw$hf7, probs),
    HD = quantile(df.raw$hd, probs),
    "THD-SQRT" = quantile(df.raw$thd, probs)
  )
  rownames(df) <- c()
  print(kable(df, col.names = c("quantile", "HF7", "HD", "THD-SQRT")))
}
simulation1()

# Simulation 2
simulation2 <- function() {
  calc.efficiency <- function(distribution, n, p) {
    true.value <- distribution$q(p)
    calc.mse <- function() {
      df <- data.frame(t(replicate(200, {
        x <- distribution$r(n)
        c(hf7 = (hf7qe(x, p) - true.value)^2,
          hd = (hdqe(x, p) - true.value)^2,
          thd = (thdqe(x, p) - true.value)^2)
      })))
      c(
        hf7 = mean(df$hf7),
        hd = mean(df$hd),
        thd = mean(df$thd)
      )
    }
    df.mse <- data.frame(t(replicate(101, calc.mse())))
    list(
      distribution = distribution$title,
      p = p,
      n = n,
      hd = median(df.mse$hf7) / median(df.mse$hd),
      thd = median(df.mse$hf7) / median(df.mse$thd)
    )
  }
  
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
  ns <- c(5) # c(3, 5, 10, 20, 40)
  ps <- seq(0.01, 0.99, by = 0.01)
  input <- expand.grid(d = ds, n = ns, p = ps)
  efficienyThreshold <- 3
  start.time <- Sys.time()
  if (!file.exists("efficiency.csv")) {
    df <- do.call("rbind",
                  lapply(1:nrow(input),
                         function(i) calc.efficiency(input$d[i][[1]], input$n[i], input$p[i])))
    df <- data.frame(df)
    df <- df %>% gather("estimator", "efficiency", -names(df)[1:3])
    df$distribution <- unlist(df$distribution)
    df$distribution <- factor(df$distribution, levels = unique(df$distribution))
    df$n <- unlist(df$n)
    df$p <- unlist(df$p)
    df$estimator <- factor(df$estimator, levels = c("hd", "thd"))
    df$efficiency <- unlist(df$efficiency)
    df$efficiency <- pmin(df$efficiency, efficienyThreshold)

    write.csv(df, "efficiency.csv", row.names = F)
  } else {
    df <- read.csv("efficiency.csv")
    df$distribution <- factor(df$distribution, levels = unique(df$distribution))
    df$estimator <- factor(df$estimator, levels = c("hd", "thd"))
  }
  end.time <- Sys.time()

  draw <- function(n) {
    p <- ggplot(df[df$n == n,], aes(x = p, y = efficiency, col = estimator)) +
      facet_wrap(vars(distribution), ncol = 5) +
      geom_hline(yintercept = 1, linetype = "dotted") +
      xlim(0, 1) +
      ylim(0, efficienyThreshold) +
      scale_color_manual(values = cbPalette, labels = c("HD", "THD-SQRT")) +
      geom_point(size = 0.2) +
      labs(
        title = paste0("Relative efficiency of quantile estimators (n = ", n, ")"),
        x = "Quantile",
        y = "Statistical efficiency",
        col = "Estimator",
        linetype = "Estimator"
      )
    show(p)
    ggsave_nice(paste0("efficiency", n), p, dpi = 200)
  }
  for (n in ns)
    draw(n)
  end.time - start.time
}
simulation2()