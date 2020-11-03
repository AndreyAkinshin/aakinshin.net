library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 5)
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

qrde.df <- function(x, step = 0.01) {
  probs <- seq(0, 1, by = step)
  q <- hdquantile(x, probs)
  x <- c()
  y1 <- c()
  y2 <- c()
  y3 <- c()
  maxH <- -1
  binArea <- 1 / (length(q) - 1)
  for (i in 1:(length(q) - 1)) {
    ql <- q[i]
    qr <- q[i + 1]
    h <- binArea / (qr - ql)
    h3 <- max(maxH, h)
    x <- c(x, ql, qr)
    y1 <- c(y1, 0, 0)
    y2 <- c(y2, h, h)
    y3 <- c(y3, h3, h3)
    maxH <- max(maxH, h)
  }
  return(data.frame(x, y1, y2, y3))
}
draw.comparison <- function(x) {
  df <- qrde.df(x, 0.001)
  tm <- theme(plot.title = element_text(size=10))
  p1 <- ggplot(df, aes(x, y = y2)) + geom_line(col = cbPalette[2], size = 0.5) + ggtitle("QRDE (Harrell-Davis)") + tm + ylab("density")
  p2 <- ggplot(df, aes(x)) + geom_histogram(col = cbPalette[3], fill = cbPalette[3], bins = 30) + ggtitle("Classic histogram") + tm
  p3 <- ggplot(df, aes(x)) + geom_density(col = cbPalette[1], fill = cbPalette[1]) + xlim(extendrange(x)) + ggtitle("KDE (Silverman's rule of thumb)") + tm
  p4 <- ggplot(df, aes(x)) + geom_density(bw = "SJ", col = cbPalette[1], fill = cbPalette[1]) + xlim(extendrange(x)) + ggtitle("KDE (Sheather & Jones)") + tm
  list(p1, p2, p3, p4)
}
draw.data <- function(name) {
  df0 <- read.csv(paste0(name, ".csv"))
  df0$isLowland <- as.logical(df0$isLowland)
  df0$isMode <- as.logical(df0$isMode)
  df0$isPeak <- as.logical(df0$isPeak)
  df0$deepWater <- ifelse(df0$isLowland, df0$water, df0$height)
  df0$shallowWater <- ifelse(!df0$isLowland, df0$water, df0$height)
  df0$middle <- (df0$left + df0$right) / 2
  
  df <- gather(df0, "type", "x", 2:3)
  df <- df[order(df$index, df$x),]
  df.gw <- df
  df.gw[df.gw$height == df.gw$water,]$height <- 0
  
  polygon.df <- function(x, y1, y2, type) {
    df.p <- data.frame(
      x = c(x, rev(x)),
      y = c(y1, rev(y2)),
      type = type
    )
  }
  df.p1 <- polygon.df(df$x, rep(0, nrow(df)), df$height, "Mountain")
  df.p2 <- polygon.df(df$x, df$height, df$deepWater, "Deep Water")
  df.p3 <- polygon.df(df$x, df$height, df$shallowWater, "Shallow Water")
  df.p4 <- polygon.df(df.gw$x, rep(0, nrow(df)), df.gw$height, "Groundwater")
  df.p <- rbind(df.p1, df.p2, df.p3, df.p4)
  df.p$type <- factor(df.p$type, levels = c("Mountain", "Deep Water", "Shallow Water", "Groundwater"))
  df.beacon <- df0[df0$isPeak,]
  df.beacon$type <- factor(ifelse(df.beacon$isMode, "Mode", "Regular Peak"), levels = c("Mode", "Regular Peak"))
  modeCount <- sum(df0$isMode)

  p <- ggplot() +
    geom_polygon(data = df.p, mapping = aes(x, y, fill = type), size = 0, alpha = 0.9) +
    geom_point(data = df.beacon, mapping = aes(x = middle, y = height, col = type), shape = 8, size = 1.5) +
    scale_fill_manual(values = c(cbPalette[1], cbPalette[5], cbPalette[2], "#625E7F")) +
    scale_color_manual(values = c(cbPalette[3], cbPalette[6])) +
    theme(legend.text = element_text(size = 7), legend.title = element_blank(), plot.title = element_text(hjust = 0.5)) +
    ylab("density") +
    ggtitle(paste0("Modality: ", modeCount))
  show(p)
  ggsave_nice(name, p)
}
draw.mvalue <- function(x, bw = "SJ", alpha = 1.0) {
  d <- density(x, bw = bw)
  max.y <- max(d$y)
  peaks <- which(diff(sign(diff(d$y)))==-2 | diff(sign(diff(-d$y)))==-2) + 1
  peaks <- c(1, peaks, length(d$x))
  n <- length(peaks)
  df <- data.frame(
    x = d$x[peaks[1:(n-1)]],
    y = d$y[peaks[1:(n-1)]],
    xend = d$x[peaks[2:n]],
    yend = d$y[peaks[2:n]]
  )
  df$xm <- (df$x + df$xend) / 2
  df$ym <- (df$y + df$yend) / 2
  df$h <- round(abs(df$yend - df$y) / max.y, 2)
  mvalue <- sum(df$h)
  ggplot() +
    geom_line(data = data.frame(x = d$x, y = d$y), aes(x, y)) + 
    geom_segment(
      data = df,
      aes(x = x, y = y, xend = xend, yend = yend),
      col = cbPalette[1],
      arrow = arrow(length = unit(0.50, "cm"), type = "closed"),
      alpha = alpha
    ) +
    geom_label(
      data = df,
      aes(x = xm, y = ym, label = h),
      col = cbPalette[2],
      alpha = alpha,
      size = 1.5
    ) +
    ggtitle(paste0("mvalue = ", mvalue)) +
    ylab("density") +
    theme(plot.title = element_text(hjust = 0.5))
}

# Modality plots
draw.data("data1") # Case: GumbelLocationProgressionNoisy(count=1, locationFactor=10, scale=1, batch=99)@0
draw.data("data2") # Case: GumbelLocationProgressionNoisy(count=2, locationFactor=10, scale=1, batch=91)@0
draw.data("data3") # Case: GumbelLocationProgressionNoisy(count=3, locationFactor=10, scale=1, batch=97)@0
draw.data("data4") # Case: GumbelLocationProgressionNoisy(count=4, locationFactor=10, scale=1, batch=110)@0
draw.data("data5") # Case: GumbelLocationProgressionNoisy(count=5, locationFactor=10, scale=1, batch=101)@0
draw.data("data6") # Case: GumbelLocationProgressionNoisy(count=6, locationFactor=10, scale=1, batch=102)@0
draw.data("data7") # Case: GumbelLocationProgressionNoisy(count=7, locationFactor=10, scale=1, batch=106)@0
draw.data("data8") # Case: GumbelLocationProgressionNoisy(count=8, locationFactor=10, scale=1, batch=108)@0
draw.data("data9") # Case: GumbelLocationProgression(count=9, locationFactor=10, scale=1, batch=100)@0
draw.data("data10") # Case: GumbelLocationProgression(count=10, locationFactor=10, scale=1, batch=100)@0

draw.data("data-close-05") # Case: CloseModes(delta = 0.5, batch=100000)@0
draw.data("data-close-01") # Case: CloseModes(delta = 0.1, batch=100000)@0
draw.data("data-close-001") # Case: CloseModes(delta = 0.01, batch=100000)@0
x <- read.csv("data-close-001-raw.csv")$value
pl <- draw.comparison(x)
ggsave_nice2("data-close-001-comparison", pl)

# Riddle
set.seed(2)
x <- rnorm(30)
ggplot(data.frame(x = x), aes(x)) + geom_density(bw = 0.1, fill = cbPalette[1]) + xlim(-3, 2.5)
ggsave_nice("riddle")
d <- density(x, bw = 0.1)
d$x[which(diff(sign(diff(d$y)))==-2)+1] # local maxima

# mvalue plots
set.seed(41)
x <- rnorm(1000)
draw.mvalue(x)
ggsave_nice("mvalue1")

draw.mvalue(c(x, x + 10), 1)
ggsave_nice("mvalue2")

draw.mvalue(c(x, x + 10, x + 20), 1)
ggsave_nice("mvalue3")

set.seed(42)
x <- c(rnorm(100, 0), rnorm(200, 10), rnorm(300, 20), rnorm(1200, 30), rnorm(300, 40), rnorm(200, 50), rnorm(100, 60))
ggplot(data.frame(x), aes(x)) + geom_density(bw = 1)
ggsave_nice("mvalue4a")
draw.mvalue(x, 1)
ggsave_nice("mvalue4b")

set.seed(42)
x <- rnorm(1000)
ggplot(data.frame(x), aes(x)) + geom_density(bw = 0.03)
ggsave_nice("mvalue5a")
draw.mvalue(x, 0.03572, 0.5)
ggsave_nice("mvalue5b")
