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
library(gridExtra)
library(evd)
library(ggplot2)
library(e1071)
library(rmutil)
library(purrr)
library(EnvStats)

rm(list = ls())

# Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 200) {
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

# Functions
quantile.hd <- function(x, probs) sapply(probs, function(p) {
  n <- length(x)
  if (n == 0) return(NA)
  if (n == 1) return(x)
  x <- sort(x)
  a <- (n + 1) * p; b <- (n + 1) * (1 - p)
  cdfs <- pbeta(0:n/n, a, b)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x * W)
})
quantile.thd <- function(x, probs, width = 1/sqrt(length(x))) sapply(probs, function(p) {
  getBetaHdi <- function(a, b, width) {
    eps <- 1e-9
    if (a < 1 + eps & b < 1 + eps) # Degenerate case
      return(c(NA, NA))
    if (a < 1 + eps & b > 1) # Left border case
      return(c(0, width))
    if (a > 1 & b < 1 + eps) # Right border case
      return(c(1 - width, 1))
    if (width > 1 - eps)
      return(c(0, 1))
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
  n <- length(x)
  if (n == 0) return(NA)
  if (n == 1) return(x)
  x <- sort(x)
  a <- (n + 1) * p; b <- (n + 1) * (1 - p)
  hdi <- getBetaHdi(a, b, width)
  hdiCdf <- pbeta(hdi, a, b)
  cdf <- function(xs) {
    xs[xs <= hdi[1]] <- hdi[1]
    xs[xs >= hdi[2]] <- hdi[2]
    (pbeta(xs, a, b) - hdiCdf[1]) / (hdiCdf[2] - hdiCdf[1])
  }
  iL <- floor(hdi[1] * n); iR <- ceiling(hdi[2] * n)
  cdfs <- cdf(iL:iR/n)
  W <- tail(cdfs, -1) - head(cdfs, -1)
  sum(x[(iL + 1):iR] * W)
})

thdme <- function(x) as.numeric(quantile.thd(x, 0.5))
hdme <- function(x) as.numeric(hdquantile(x, 0.5))
hlme <- function(x, f) {
  n <- length(x)
  df <- expand.grid(i = 1:n, j = 1:n)
  df <- df[f(df$i, df$j),]
  df$r <- (x[df$i] + x[df$j]) / 2
  median(df$r)
}
hl1me <- function(x) hlme(x, function(i, j) i < j)
hl2me <- function(x) hlme(x, function(i, j) i <= j)
hl3me <- function(x) hlme(x, function(i, j) T)

# Main
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
ds.names <- sapply(ds, function(d) d$title)

simulation.efficiency <- function() {
  ns <- 5:20
  input <- expand.grid(d = ds, n = ns)
  repetitions <- 1000
  
  calc <- function(distribution, n) {
    x <- distribution$r(n)
    data.frame(t(replicate(repetitions, {
      x <- distribution$r(n)
      c(distribution = distribution$title,
        n = n,
        expected = distribution$q(0.5),
        sm = median(x),
        thd = thdme(x),
        hd = hdme(x),
        hl1 = hl1me(x),
        hl2 = hl2me(x),
        hl3 = hl3me(x))
    })))
  }
  
  filename.eff <- "eff.csv"

  if (!file.exists(filename.eff)) {
    df.raw <- do.call("rbind", lapply(1:nrow(input), function(i) calc(input$d[i][[1]], input$n[i])))
    df.raw <- df.raw %>% gather("estimator", "estimation", -distribution, -n, -expected)
    df.raw$estimation <- as.numeric(df.raw$estimation)
    df.raw$expected <- as.numeric(df.raw$expected)
    df.mse <- df.raw %>%
      group_by(distribution, estimator, n) %>%
      summarise(mse = round(var(estimation) + (mean(estimation) - mean(expected))^2, 5)) %>%
      spread("estimator", "mse") %>%
      data.frame()
    head(df.mse)

    write.csv(df.mse, filename.eff, row.names = F)
  } else {
    read <- function(filename) {
      df0 <- read.csv(filename)
      df0$distribution <- factor(df0$distribution, levels = ds.names)
      df0
    }
    df.mse <- read(filename.eff)
  }
  
  list(mse = df.mse)
}

figure.efficiency <- function() {
  s <- simulation.efficiency()
  df.eff <- s$mse
  df.eff$hd <- df.eff$sm / df.eff$hd
  df.eff$thd <- df.eff$sm / df.eff$thd
  df.eff$hl1 <- df.eff$sm / df.eff$hl1
  df.eff$hl2 <- df.eff$sm / df.eff$hl2
  df.eff$hl3 <- df.eff$sm / df.eff$hl3
  df.eff <- df.eff[,!(names(df.eff) %in% c("sm"))]
  df.plot <- df.eff %>% gather("estimator", "eff", -distribution, -n)
  df.plot$estimator <- factor(df.plot$estimator, levels = c("hd", "thd", "hl1", "hl2", "hl3"))
  df.plot$n <- as.numeric(df.plot$n)
  df.plot$eff <- as.numeric(df.plot$eff)
  df.plot$distribution <- factor(df.plot$distribution, levels = ds.names)
  ggplot(df.plot, aes(n, eff, col = estimator)) +
    facet_wrap(vars(distribution), scales = "free", ncol = 4) +
    scale_color_manual(values = cbPalette, labels = c("HD", "THD-SQRT", "HL1", "HL2", "HL3")) +
    labs(y = "Relative statistical efficiency", col = "") +
    geom_hline(yintercept = 1, col = cbGrey) +
    geom_line() +
    theme(legend.position = "bottom", text = element_text(size = 8))
}
figure.efficiency()
ggsave_nice("eff")
