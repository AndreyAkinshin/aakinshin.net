# Libraries

## Init pacman
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_unload(all)
library(pacman)

## Plotting
p_load(ggplot2)
p_load(ggdark)
p_load(gridExtra)
p_load(latex2exp)
p_load(ggpubr)

## Data manipulation
p_load(dplyr)
p_load(plyr)
p_load(tidyr)

## Misc
p_load(Hmisc)
p_load(evd)
p_load(knitr)
p_load(rootSolve)

#-------------------------------------------------------------------------------
# Preparation

## Clear the environment
rm(list = ls())

## A color palette adopted for color-blind people based on https://jfly.uni-koeln.de/color/
cbp <- list(red = "#D55E00", blue = "#56B4E9", green = "#009E73", orange = "#E69F00",
            navy = "#0072B2", pink = "#CC79A7", yellow = "#F0E442", grey = "#999999")

## A smart ggsave wrapper
ggsave_ <- function(name, plot = last_plot(), basic.theme = theme_bw(), multithemed = T, ext = "png",
                    dpi = 300, width.px = 1.5 * 1600, height.px = 1.6 * 900) {
  if (class(name) == "function") {
    plot <- name()
    name <- as.character(match.call()[2])
    if (startsWith(name, "figure."))
      name <- substring(name, nchar("figure.") + 1)
  }

  width <- width.px / dpi
  height <- height.px / dpi
  if (multithemed) {
    old_theme <- theme_set(basic.theme)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(basic.theme, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(basic.theme)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

#-------------------------------------------------------------------------------
# Functions & data

mad <- function(x) median(abs(x - median(x)))
d.trimodal <- list(
  title = "A trimodal distribution",
  d = function(x) dbeta(x, 1.5, 1.5) / 4 + dbeta(x - 4, 1.5, 1.5) / 2 + dbeta(x - 8, 1.5, 1.5) / 4,
  r = function(n) {
    r1 <- rbeta(n, 1.5, 1.5)
    r2 <- rbeta(n, 1.5, 1.5) + 4
    r3 <- rbeta(n, 1.5, 1.5) + 8
    m <- rbind(r1, r2, r2, r3)
    ind <- sample(1:nrow(m), n, T)
    sapply(1:n, function(i) m[ind[i], i])
  }
)

#-------------------------------------------------------------------------------
# Tables

table.frechet <- function() {
  M <- qfrechet(0.5)
  MAD <- uniroot.all(function(mad) pfrechet(M + mad) - pfrechet(M - mad) - 0.5,
                     c(0, 10), tol = 1e-15)
  f <- function(coef) pfrechet(M + MAD * coef) - pfrechet(M - MAD * coef)
  
  coefs <- c(1, 1.48, 2.97, 4.45)
  df <- data.frame(C = coefs, P = sapply(coefs, function(C) round(f(C), 3)))
  kable(df)
}

#-------------------------------------------------------------------------------
# Figures

figure.instability1 <- function() {
  x <- seq(0, 9, by = 0.01)
  y <- d.trimodal$d(x)
  df.density <- data.frame(x, y)
  df.labels <- data.frame(
    x = c(0.5, 4.5, 8.5),
    y = c(0.1, 0.1, 0.1),
    label = c("25%", "50%", "25%"),
    size = c(5, 8, 5))
  ggplot(df.density, aes(x, y)) +
    geom_line() +
    geom_text(data = df.labels, size = df.labels$size, aes(x, y, label = label)) +
    scale_x_continuous(breaks = seq(0, 9, by = 1)) +
    ggtitle("A trimodal distribution") +
    labs(y = "Density") +
    theme(legend.position = "none")
}

figure.instability2 <- function() {
  set.seed(1729)
  x <- replicate(1000, mad(d.trimodal$r(100)))
  ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ") +
    scale_x_continuous(breaks = seq(0, 6, by = 1), limits = c(0, 5)) +
    ggtitle("Distribution of MAD estimations from a trimodal distribution") +
    labs(y = "Density")
}

figure.zero1 <- function() {
  lambda <- 0.6
  x <- 0:6
  y <- dpois(0:6, lambda)
  df <- data.frame(
    x = x,
    y = y,
    yend = rep(0, length(x)),
    ytext = y + 0.05,
    label = signif(y, 2),
    lambda = lambda
  )
  ggplot(df, aes(x = x, y = y, xend = x, yend = yend)) +
    geom_point() +
    geom_segment() +
    scale_x_continuous(breaks = seq(min(df$x), max(df$x), by = 1)) +
    scale_y_continuous(limits = c(0, max(df$y) + 0.2)) +
    ggtitle(paste0("Poisson distribution for λ=", lambda)) +
    labs(y = "Probability") +
    geom_text(aes(x, ytext, label = label))
}

figure.zero2 <- function() {
  x <- seq(0, 3, by = 0.01)
  y <- dnorm(x) / 2
  y[x < 0] <- 0
  ggplot(data.frame(x, y), aes(x, y)) +
    geom_line() +
    geom_segment(x = 0, y = 0, xend = 0, yend = 0.25) +
    geom_point(x = 0, y = 0.25, shape = 17, size = 3) +
    annotate("text", x = 0, y = 0.25, hjust = -0.4, label = "0.5") +
    ggtitle("Rectified gaussian distribution") +
    ylab("Density") +
    xlim(0, 3) + ylim(0, 0.25)
}

figure.normality1 <- function() {
  stat_function_fill <- function(fill, xlim) {
    stat_function(fun = dnorm, geom = "area", fill = "transparent", xlim = xlim)
  }
  
  geom_vsegm <- function(x0, linetype = "dashed") {
    geom_segment(aes(x = x0, y = 0, xend = x0, yend = dnorm(x0)), linetype = linetype)
  }
  
  ticks <- c(
    TeX("$\\bar{x}-4\\sigma$"),
    TeX("$\\bar{x}-3\\sigma$"),
    TeX("$\\bar{x}-2\\sigma$"),
    TeX("$\\bar{x}-1\\sigma$"),
    TeX("$\\bar{x}$"),
    TeX("$\\bar{x}+1\\sigma$"),
    TeX("$\\bar{x}+2\\sigma$"),
    TeX("$\\bar{x}+3\\sigma$"),
    TeX("$\\bar{x}+4\\sigma$"))
  
  ggplot(data.frame(x = c(-4, 4)), aes(x)) +
    stat_function(fun = dnorm) +
    stat_function_fill(cbp$orange, c(-3, -2)) +
    stat_function_fill(cbp$blue, c(-2, -1)) +
    stat_function_fill(cbp$red, c(-1, +1)) +
    stat_function_fill(cbp$blue, c(+1, +2)) +
    stat_function_fill(cbp$orange, c(+2, +3)) +
    ggtitle("The normal distribution") +
    labs(x = "x", y = "Density") +
    geom_vsegm(-3) +
    geom_vsegm(-2) +
    geom_vsegm(-1) +
    geom_vsegm(0, "solid") +
    geom_vsegm(1) +
    geom_vsegm(2) +
    geom_vsegm(3) +
    geom_text(x =  0.55, y = 0.180, size = 4.5, label = "34.1%") +
    geom_text(x = -0.55, y = 0.180, size = 4.5, label = "34.1%") +
    geom_text(x =  1.45, y = 0.050, size = 3.8, label = "13.6%") +
    geom_text(x = -1.45, y = 0.050, size = 3.8, label = "13.6%") +
    geom_text(x =  2.3,  y = 0.008, size = 2.9, label =  "2.14%") +
    geom_text(x = -2.3,  y = 0.008, size = 2.9, label =  "2.14%") +
    scale_x_continuous(breaks = c(-4:4), labels = ticks)
}

figure.normality2 <- function() {
  M <- qfrechet(0.5)
  MAD <- uniroot.all(function(mad) pfrechet(M + mad) - pfrechet(M - mad) - 0.5,
                     c(0, 10), tol = 1e-15)
  
  build.df <- function() {
    x <- seq(0, 10, by = 0.01)
    data.frame(
      x = seq(0, 10, by = 0.01),
      y = dfrechet(x))
  }
  build.df.seg <- function() {
    x <- c(
      M - 4.45 * MAD, M - 2.97 * MAD, M - 1.48 * MAD, M - MAD, M,
      M + MAD, M + 1.48 * MAD, M + 2.97 * MAD, M + 4.45 * MAD)
    df.seg <- data.frame(
      x = x,
      y = dfrechet(x),
      ytext = dfrechet(x) + 0.01,
      yend = rep(0, length(x)),
      angle = c(rep(-45, 3), rep(0, 6)),
      hjust = c(rep(1.1, 3), rep(0, 6)),
      vjust = c(rep(0.3, 3), rep(-0.5, 6)),
      linetype = c(rep("dashed", 4), "solid", rep("dashed", 4)),
      label = c("M - 4.45 MAD", "M - 2.97 MAD", "M - 1.48 MAD", "M - MAD", "M",
                "M + MAD", "M + 1.48 MAD", "M + 2.97 MAD", "M + 4.45 MAD")
    )
  }
  df <- build.df()
  df.seg <- build.df.seg()
  braket <- function(x1, x2, depth) {
    df <- data.frame(
      x = c(x1, x1, x2, x2),
      y = c(0, depth, depth, 0) * -0.01
    )
    geom_path(data = df, aes(x, y), col = cbp$red, linetype = "dashed")
  }
  ggplot(df, aes(x, y)) +
    geom_line(size = 1.2) +
    geom_segment(aes(x, y, xend = x, yend = yend),
                 df.seg, col = cbp$red, linetype = df.seg$linetype) +
    geom_point(data = df.seg, col = cbp$red) +
    geom_text(aes(x, ytext, label = label, hjust = hjust, vjust = vjust, angle = angle),
              df.seg, size = 2.5, col = cbp$red) +
    scale_x_continuous(limits = c(min(df.seg$x) - 0.5, max(df$x)), breaks = seq(-3, 10, by = 1)) +
    ggtitle("Frechet distribution") +
    labs(y = "Density") +
    braket(M - MAD, M + MAD, 1) +
    braket(M - 1.48 * MAD, M + 1.48 * MAD, 2) +
    braket(M - 2.97 * MAD, M + 2.97 * MAD, 3) +
    braket(M - 4.45 * MAD, M + 4.45 * MAD, 4)
}

#-------------------------------------------------------------------------------
# Plotting

## Remove all existing images
for (file in list.files())
  if (endsWith(file, ".png"))
    file.remove(file)

## Draw all the defined figures
for (func in lsf.str()) {
  if (startsWith(func, "figure.")) {
    name <- substring(func, nchar("figure.") + 1)
    ggsave_(name, get(func)())
  }
}
