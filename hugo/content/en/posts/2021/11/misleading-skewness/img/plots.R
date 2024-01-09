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

# Main
draw.skew_intro <- function() {
  set.seed(42)
  df <- data.frame(
    A = rbeta(10000, 5, 2),
    B = rbeta(10000, 5, 5),
    C = rbeta(10000, 2, 5)
  )
  
  titles <- c(
    A = "Negative Skewnewss\nSkewed Left\nMean<Median",
    B = "Zero Skewness\nSymmetric\nMean=Median",
    C = "Positive Skewness\nSkewed Right\nMean>Median"
  )
  
  p <- ggplot(df %>% gather("distribution", "value"), aes(x = value)) + 
    geom_density(alpha=.5, fill= cbBlue, col = cbBlue, bw = "SJ") +
    xlab("") + ylab("") +
    facet_grid(. ~ distribution, labeller = labeller(distribution = titles)) +
    theme(strip.text.x = element_text(size = 12))
  ggsave_nice("skew_intro", p)
}
draw.multimodal <- function() {
  set.seed(42)
  x <- c(
    rlnorm(1000, 0, 3),
    9 - rlnorm(500, 0, 1),
    10 + rlnorm(600, 0, 1)
  )
  ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ", col = cbBlue, fill = cbBlue, alpha = .5) +
    xlim(-1, 15) +
    ggtitle("Multimodal distribution")
  ggsave_nice("multimodal")
}
draw.beta <- function() {
  sk <- function(x) {
    sum((x - mean(x))^3) / sd(x)^3 / length(x)
  }
  
  set.seed(42)
  x <- rbeta(10000, 2, 10)
  ggplot(data.frame(x = x), aes(x)) +
    geom_density(bw = "SJ", col = cbBlue, fill = cbBlue, alpha = .5) +
    xlim(0, 1)
  ggsave_nice("beta")
  print(sk(x))
  print(sk(c(-1000, x)))
}
draw.consistency <- function(filename, title, gen) {
  sk <- function(x) {
    sum((x - mean(x))^3) / sd(x)^3 / length(x)
  }
  calc <- function(x) {
    s <- sk(x)
    c(s = s, d = mean(x) - median(x))
  }
  
  set.seed(42)
  df <- data.frame(t(rbind(replicate(1000, calc(gen())))))
  TC <- "consistent"
  TI <- "inconsistent"
  df$type <- ifelse(sign(df$s) == sign(df$d), TC, TI)
  df$type <- factor(df$type, levels = c(TC, TI))
  p <- ggplot(df, aes(x = s, y = d, col = type)) +
    geom_point() +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
    scale_color_manual(
      values = c(cbGreen, cbRed),
      labels = c(
        paste0(TC, " (", sum(df$type == TC), ")"), 
        paste0(TI, " (", sum(df$type == TI), ")"))) +
    labs(
      title = paste0("Skewness consistency scatterplot for random samples from ", title),
      x = "Skewness(x)  [Joanes-Christine b1]",
      y = "Mean(x) - Median(x)",
      col = ""
    )
  ggsave_nice(paste0("consistency-", filename), p)
}

draw.skew_intro()
draw.multimodal()
draw.beta()
draw.consistency("norm", "N(0, 1)", function() rnorm(100))
draw.consistency("unif", "U(0, 1)", function() runif(100))
draw.consistency("beta", "Beta(10, 2)", function() rbeta(100, 10, 2))
draw.consistency("gumbel", "Gumbel", function() rgumbel(100))