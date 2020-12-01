library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)
library(plyr)

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

hdmedian <- function(x) as.numeric(hdquantile(x, 0.5))
qrde.df <- function(x, type, step) {
  probs <- seq(0, 1, by = step)
  q <- hdquantile(x, probs)
  x <- c()
  y <- c()
  factor <- 1 / (length(q) - 1)
  for (i in 1:(length(q) - 1)) {
    ql <- q[i]
    qr <- q[i + 1]
    h <- factor / (qr - ql)
    x <- c(x, ql, qr)
    y <- c(y, h, h)
  }
  x <- c(x[1], x, x[length(x)])
  y <- c(0, y, 0)
  return(data.frame(x, y))
}
draw.qrde <- function(x, step = 0.001) {
  df.raw <- data.frame(x = x, y = 0)
  df <- qrde.df(x, type, step)
  ggplot(df, aes(x, y)) +
    geom_line(col = cbBlue) +
    geom_rug(data = df.raw, mapping = aes(x), sides = "b", col = cbRed) +
    ggtitle("QRDE-HD") +
    ylab("density") +
    theme(plot.title = element_text(hjust = 0.5))
}
draw <- function(name, values, step = 0.01) {
  p1 <- seq(0, 1, by = step)
  p2 <- seq(0, 1, by = step)
  dfl <- lapply(p1, function(u) {
    v <- abs(values - hdquantile(values, u))
    z <- hdquantile(v, p2)
    data.frame(p1 = u, p2 = p2, z = z)
  })
  df <- ldply(dfl, data.frame)

  p1 <- draw.qrde(values)
  ggsave_nice(paste0(name, "-den"), p1)
  
  p2 <- ggplot(df, aes(p1, p2, z = z)) +
    geom_contour_filled(breaks = hdquantile(df$z, seq(0, 1, by = 0.05)), col = "black") +
    ggtitle("QAD Heatmap") +
    xlab("p") +
    ylab("q") +
    guides(fill = guide_legend(ncol = 2)) +
    theme(legend.text = element_text(size = 7),
          legend.key.size = unit(0.5, "cm"),
          plot.title = element_text(hjust = 0.5),
          axis.title.y = element_text(angle = 0, vjust = 0.5))
  ggsave_nice(name, p2)
}

draw.gumbel.mad <- function() {
  segment <- function(x1, y1, x2, y2, col) geom_segment(
    data = data.frame(x1 = x1, x2 = x2, y1 = y1, y2 = y2),
    aes(x = x1, y = y1, xend = x2, yend = y2),
    col = col, linetype = "dashed")
  show_value <- function(x, col) segment(x, 0, x, dgumbel(x), col)
  show_text <- function(x, text, col, hjust)
    annotate("text", x = x - (hjust - 0.5) * 0.5, y = dgumbel(x), label = text, hjust = hjust, col = col)
  
  x <- seq(-4, 7, by = 0.001)
  y <- dgumbel(x)
  df <- data.frame(x = x, y = y)
  med <- -log(log(2)) # Median
  mad0 <- 0.767049251325708 # Median absolute deviation
  xm <- seq(med - mad0, med + mad0, by = 0.001)
  ym <- dgumbel(xm)
  xm <- c(med - mad0, xm, med + mad0)
  ym <- c(0, ym, 0)
  dfm <- data.frame(x = xm, y = ym)
  pm <- ggplot() +
    geom_polygon(data = dfm, mapping = aes(x, y), fill = cbPalette[3], alpha = 0.3) +
    show_value(med, cbPalette[1]) +
    show_text(med, "M", cbPalette[1], 0) +
    show_value(med - mad0, cbPalette[2]) +
    show_text(med - mad0, "M-MAD", cbPalette[2], 1) +
    show_value(med + mad0, cbPalette[2]) +
    show_text(med + mad0, "M+MAD", cbPalette[2], 0) +
    geom_line(data = df, mapping = aes(x, y)) +
    annotate("text", x = med, y = dgumbel(med) / 2, label = "50%", size = 6) +
    annotate("text", x = med - mad0 * 1.7, y = dgumbel(med - mad0 * 1.7) / 4, label = "22.48%", size = 2.5) +
    annotate("text", x = med + mad0 * 2.1, y = dgumbel(med - mad0 * 1.7) / 4, label = "27.52%", size = 2.5) +
    ylab("PDF(x)") +
    ggtitle("Probability density function (Gumbel distribution)")
  ggsave_nice("gumbel-mad", pm)
}
draw.gumbel.mad()

draw.mad <- function(name, values) {
  p1 <- draw.qrde(values)
  probs <- seq(0, 1, by = 0.01)
  mads <- sapply(probs, function(p) hdmedian(abs(values - hdquantile(values, p))))
  p2 <- ggplot(data.frame(probs, mads), aes(x = probs, y = mads)) +
    geom_line(col = cbPink) +
    xlab("p") +
    ylab("MAD") +
    ggtitle("MAD(x, p)") +
    theme(plot.title = element_text(hjust = 0.5))
  ggarrange(p1, p2)
  ggsave_nice2(name, list(p1, p2))
}


set.seed(42)
values <- c(rnorm(50, 100))
draw.mad("mad-unimodal", values)

set.seed(42)
values <- c(rnorm(50, 100), 120, 130, 140, 150)
draw.mad("mad-unimodal-outliers", values)

set.seed(42)
values <- c(50 + 50 * rbeta(200, 1.5, 10))
draw.mad("mad-skewed", values)

draw.qad <- function(name, values) {
  p1 <- draw.qrde(values)
  qad.plot <- function(q) {
    probs <- seq(0, 1, by = 0.01)
    mads <- sapply(probs, function(p) hdquantile(abs(values - hdquantile(values, p)), q))
    ggplot(data.frame(probs, mads), aes(x = probs, y = mads)) +
      geom_line(col = cbPink) +
      xlab("p") +
      ylab("QAD") +
      ggtitle(paste0("QAD(x, p, ", q, ")")) +
      theme(plot.title = element_text(hjust = 0.5))
  }
  p2 <- qad.plot(0.25)
  p3 <- qad.plot(0.50)
  p4 <- qad.plot(0.75)
  ggarrange(p1, p2, p3, p4)
  ggsave_nice2(name, list(p1, p2, p3, p4))
}

set.seed(42)
values <- c(rnorm(100, 100), rnorm(100, 150))
draw.qad("qad-modal2", values)

set.seed(42)
values <- c(rnorm(100, 100), rnorm(100, 150), rnorm(100, 200))
draw.qad("qad-modal3", values)


for (modes in c(1, 2, 3, 4, 5, 10)) {
  set.seed(42)
  values <- c(sapply(1:modes, function(i) rnorm(500 / modes, 10 * i)))
  draw(paste0("modal", modes), values)
}

set.seed(42)
values <- c(50, 60, 70, 80, rnorm(50, 100))
draw("outliers-lower", values)

set.seed(42)
values <- c(rnorm(50, 100), 120, 130, 140, 150)
draw("outliers-upper", values)

set.seed(42)
values <- c(50, 60, 70, 80, rnorm(50, 100), 120, 130, 140, 150)
draw("outliers-both", values)

set.seed(42)
values <- 10 + 10 * rbeta(100, 1, 20)
draw("skewed-right", values)

set.seed(42)
values <- 10 + 10 * rbeta(100, 20, 1)
draw("skewed-left", values)