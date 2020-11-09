library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 5)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "svg", dpi = 300) {
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
ggsave_nice2 <- function(name, plots, tm = theme_bw(), dark_and_light = TRUE, ext = "svg", dpi = 300) {
  width <- 1600 / dpi
  height <- 900 / dpi
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    plot <- ggarrange(plotlist = plots)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    plot <- ggarrange(plotlist = plots)
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

kdequantile <- function(x, bw, prob) uniroot(function(u) sum(pnorm(u, x, bw)) / length(x) - prob, c(-100, 100))$root

# KDE-PDF with quantiles
x <- c(3, 4, 7)
bw <- 0.7
q1 <- 0.5
q2 <- 0.95
medians <- data.frame(
  value = c(quantile(x, q1), hdquantile(x, q1), kdequantile(x, bw, q1),
            quantile(x, q2), hdquantile(x, q2), kdequantile(x, bw, q2)),
  y1 = rep(0, 6),
  y2 = rep(max(density(x, bw = bw)$y), 6),
  cols = rep(c(cbPalette[6], cbPalette[4], cbPalette[5]), 2),
  type = rep(c("Type7", "Harrell-Davis", "KDE"), 2),
  quantile = c(rep("Median", 3), rep("95th percentile", 3))
)
p <- ggplot(data.frame(x), aes(x)) +
  geom_density(bw = 0.7, fill = cbPalette[1], alpha = 0.1) +
  geom_rug(col = cbPalette[2], size = 2) +
  geom_segment(
    data = medians,
    mapping = aes(x = value, y = y1, xend = value, yend = y2, col = type, linetype = quantile),
    size = 0.9) +
  scale_color_manual(name = "Qunatile Type", values = medians$cols) +
  scale_linetype_manual(name = "Quantile Value", values = c("solid", "dotted")) +
  scale_x_continuous(breaks = seq(1, 9, by = 1), limits = c(1, 9)) +
  theme(legend.key.width = unit(0.5, "inches"))
ggsave_nice("three-elements")

# QRDE
qrde.df <- function(x, type, step) {
  probs <- seq(0, 1, by = step)
  if (type == "Type7")
    q <- quantile(x, probs)
  else if (type == "Harrell-Davis")
    q <- hdquantile(x, probs)
  else
    stop(paste0("Unknown type: ", type))
  x <- c()
  y <- c()
  factor <- 1 / (length(q) - 1)
  for (i in 1:(length(q) - 1)) {
    ql <- q[i]
    qr <- q[i + 1]
    h <- factor / (qr - ql)
    x <- c(x, ql, ql, qr, qr)
    y <- c(y, 0, h, h, 0)
  }
  return(data.frame(x, y, type))
}
qrde.df2 <- function(x, step) {
  df <- rbind(qrde.df(x, "Type7", step), qrde.df(x, "Harrell-Davis", step))
  df$type <- factor(df$type, levels = c("Type7", "Harrell-Davis"))
  return(df)
}
draw.qrde <- function(x, step, comment, type = "") {
  if (type != "")
    df <- qrde.df(x, type, step)
  else
    df <- qrde.df2(x, step)
  ggplot(df, aes(x, y)) +
    geom_line(col = cbPalette[2]) +
    facet_grid(cols = vars(type)) +
    ggtitle(paste0("QRDE (step = ", step, "), ", comment)) +
    theme(plot.title = element_text(hjust = 0.5))
}

draw.qrde(c(3, 4, 7), 0.1, "x={3,4,7}")
ggsave_nice("qrde-347")

set.seed(42)
x <- rnorm(500)
draw.qrde(x, 0.1, "normal distribution, n = 500")
ggsave_nice("qrde-norm-500-01")
draw.qrde(x, 0.01, "normal distribution, n = 500")
ggsave_nice("qrde-norm-500-001")

set.seed(44)
x <- rnorm(500)
draw.qrde(x, 0.001, "normal distribution, n = 500", "Type7")
ggsave_nice("qrde-norm-500-0001-t7")
draw.qrde(x, 0.001, "normal distribution, n = 500", "Harrell-Davis")
ggsave_nice("qrde-norm-500-0001-hd")

# QRDE vs. Histograms vs. KDE
draw.comparison <- function(x) {
  df <- qrde.df(x, "Harrell-Davis", 0.001)
  tm <- theme(plot.title = element_text(size=10))
  p1 <- ggplot(df, aes(x, y)) + geom_line(col = cbPalette[2]) + ggtitle("QRDE (Harrell-Davis)") + tm
  p2 <- ggplot(df, aes(x)) + geom_histogram(col = cbPalette[3], fill = cbPalette[3], bins = 30) + ggtitle("Classic histogram") + tm
  p3 <- ggplot(df, aes(x)) + geom_density(col = cbPalette[1], fill = cbPalette[1]) + xlim(extendrange(x)) + ggtitle("KDE (Silverman's rule of thumb)") + tm
  p4 <- ggplot(df, aes(x)) + geom_density(bw = "SJ", col = cbPalette[1], fill = cbPalette[1]) + xlim(extendrange(x)) + ggtitle("KDE (Sheather & Jones)") + tm
  list(p1, p2, p3, p4)
}
draw.comparison.multi <- function(seed, modeCount, n, dist) {
  if (seed != 0)
    set.seed(seed)
  x <- c(unlist(sapply(1:modeCount, function(i) rnorm(n, i * dist))))
  draw.comparison(x)
}
pl <- draw.comparison(c(runif(1000, min = 0, max = 10), rnorm(100, 5, 0.1), rnorm(100, 5.5, 0.1)))
ggsave_nice2("comparison-2", pl)
pl <- draw.comparison.multi(12, 4, 30, 4)
ggsave_nice2("comparison-4", pl)
pl <- draw.comparison.multi(11, 20, 100, 4)
ggsave_nice2("comparison-20", pl)