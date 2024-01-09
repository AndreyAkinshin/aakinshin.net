library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 300) {
  width <- 1600 / dpi
  height <- 900 / dpi
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

pooled <- function(x, y, FUN) {
  nx <- length(x)
  ny <- length(y)
  sqrt(((nx - 1) * FUN(x) ^ 2 + (ny - 1) * FUN(y) ^ 2) / (nx + ny - 2))
}
hdmedian <- function(x) as.numeric(hdquantile(x, 0.5))
hdmad <- function(x) 1.4826 * hdmedian(abs(x - hdmedian(x)))
phdmad <- function(x, y) pooled(x, y, hdmad)
gammaEffectSize <- function(x, y, prob)
  as.numeric((hdquantile(y, prob) - hdquantile(x, prob)) / phdmad(x, y))

create.df <- function(n, outlier, r = 1000) {
  data.cohen <- c()
  data.gamma <- c()
  for (iter in 1:r) {
    x <- rnorm(n)
    y <- c(rnorm(n - 1, 1), outlier)
    data.cohen <- c(data.cohen, cohen.d(y, x)$estimate)
    data.gamma <- c(data.gamma, gammaEffectSize(x, y, 0.5))
  }
  data.frame(n = rep(n, r), outlier = rep(outlier, r), cohen = data.cohen, gamma = data.gamma)
}
  
set.seed(42)
input <- expand.grid(n = c(50, 500, 1000), outlier = c(100))
dfs <- apply(input, 1, function(row) create.df(row[1], row[2]))
df <- ldply(dfs, data.frame) %>% gather("metric", "value", 3:4)
df$metric <- factor(df$metric, levels = c("cohen", "gamma"))

ggplot(df[df$metric == "cohen",], aes(value, fill = metric)) +
  geom_density(bw = "SJ", alpha = 0.8) +
  geom_vline(xintercept = 1, col = cbPink, fill = cbPink, size = 0.5) +
  facet_grid(rows = vars(n), labeller = labeller(.rows = label_both)) +
  scale_fill_manual(
    values = c(cbRed, cbGreen),
    labels = c("Cohen's d", "γ(0.5)")) +
  scale_x_continuous(limits = c(0, 1.5), breaks = seq(0, 1.5, by = 0.1)) +
  annotate("text", x = 1, y = 18, label = "True Value", hjust = -0.1, col = cbPink) +
  theme(legend.title=element_blank())
ggsave_nice("cohen")

ggplot(df, aes(value, fill = metric)) +
  geom_density(bw = "SJ", alpha = 0.8) +
  geom_vline(xintercept = 1, col = cbPink, fill = cbPink, size = 0.5) +
  facet_grid(rows = vars(n), labeller = labeller(.rows = label_both)) +
  scale_fill_manual(
    values = c(cbRed, cbGreen),
    labels = c("Cohen's d", "γ(0.5)")) +
  scale_x_continuous(limits = c(0, 1.5), breaks = seq(0, 1.5, by = 0.1)) +
  annotate("text", x = 1, y = 18, label = "True Value", hjust = -0.1, col = cbPink) +
  theme(legend.title=element_blank())
ggsave_nice("cohen-vs-gamma")
