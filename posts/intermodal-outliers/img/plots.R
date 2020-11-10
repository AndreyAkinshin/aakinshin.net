library(ggplot2)
library(Hmisc)
library(ggdark)
library(evd)
library(svglite)
library(ggpubr)
library(tidyr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
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

doubleMadFences <- function(x) {
  hdmedian <- function(u) as.numeric(hdquantile(u, 0.5))
  
  x <- x[!is.na(x)]
  m <- hdmedian(x)
  deviations <- abs(x - m)
  lowerMAD <- 1.4826 * hdmedian(deviations[x <= m])
  upperMAD <- 1.4826 * hdmedian(deviations[x >= m])
  
  c(m - 3 * lowerMAD, m + 3 * upperMAD)
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

draw <- function(x) {
  types <- c("Lower outlier", "Mode #1", "Intermodal outliers", "Mode #2", "Upper outliers", "None")
  apply.type <- function(df, low, high, type) {
    df[df$x >= low & df$x <= high,]$type <- type
    df
  }
  apply.types <- function(df, r1, r2, r3, r4, r5) {
    df <- apply.type(df, r1[1], r1[2], types[1])
    df <- apply.type(df, r2[1], r2[2], types[2])
    df <- apply.type(df, r3[1], r3[2], types[3])
    df <- apply.type(df, r4[1], r4[2], types[4])
    df <- apply.type(df, r5[1], r5[2], types[5])
    df$type <- factor(df$type, levels = types)
    df$group <- c(0)
    for (i in 2:nrow(df)) {
      if (df[i,]$type != df[i - 1,]$type)
        df[i,]$group <- df[i - 1,]$group + 1
      else
        df[i,]$group <- df[i - 1,]$group
    }
    df
  }
  
  den <- density(x, bw = 0.2, n = 2^10)
  df.den <- data.frame(
    x = den$x,
    y = den$y,
    type = c("None")
  )
  rf <- function(a, b) range(df.den[df.den$x >= a & df.den$x < b & df.den$y > 0.00001, ]$x)
  r1 <- rf(0, 3)
  r2 <- rf(6, 14)
  r3 <- rf(17, 23)
  r4 <- rf(26, 34)
  r5 <- rf(36, 40)
  df.den <- apply.types(df.den, r1, r2, r3, r4, r5)
  
  df.rug <- data.frame(x, type = "None")
  df.rug <- apply.types(df.rug, r1, r2, r3, r4, r5)
  
  pallete <- c(cbOrange, cbNavy, cbGreen, cbBlue, cbYellow, cbGrey)
  ggplot() +
    geom_line(data = df.den, aes(x, y, col = type, group = group), size = 0.8) +
    geom_rug(data = df.rug, aes(x, col = type), size = 0.8) +
    scale_color_manual(values = head(pallete, length(types)), breaks = types) +
    theme(legend.title = element_blank()) +
    scale_x_continuous(limits = c(0, 40), breaks = seq(0, 40, by = 5)) +
    ylab("density")
}

#set.seed(43)
#n <- 100
#x <- c(1, 2, rnorm(n, 10), 19, 21, rnorm(n, 30), 38, 39)
x <- c(1, 2, 10.695, 9.71, 11.882, 9.935, 8.133, 11.701, 11.056, 11.386, 10.253, 9.701,
       11.11, 7.893, 9.842, 7.576, 8.913, 9.912, 10.473, 9.234, 10.016, 8.949, 10.505,
       10.321, 7.608, 10.64, 8.351, 8.737, 10.544, 9.9, 11.171, 9.398, 10.145, 11.411,
       7.732, 10.515, 7.16, 9.891, 10.066, 10.05, 11.327, 10.198, 9.816, 10.878, 10.271,
       11.093, 8.758, 10.656, 9.143, 8.972, 8.1, 10.255, 10.704, 10.631, 8.537, 11.462,
       9.046, 9.906, 9.356, 10.794, 9.93, 10.14, 9.371, 12.637, 10.39, 9.04, 10.729,
       10.079, 11.909, 8.498, 10.035, 7.879, 10.468, 9.677, 9.551, 9.324, 11.736, 10.341,
       9.305, 9.844, 8.662, 11.76, 9.628, 10.571, 10.639, 10.171, 9.672, 9.669, 9.696,
       11.265, 13.115, 9.655, 9.273, 10.957, 9.903, 10.426, 9.612, 9.652, 9.375, 11.348,
       8.931, 8.918, 19, 21, 30.84, 31.587, 29.535, 31.072, 29.55, 29.796, 30.071,
       29.907, 28.993, 28.683, 28.864, 28.032, 29.807, 30.77, 28.906, 30.987, 30.119
       , 32.344, 31.341, 31.557, 30.094, 30.405, 29.373, 30.029, 30.516, 29.301, 29.334
       , 29.625, 30.407, 30.466, 29.722, 30.05, 29.249, 28.212, 28.807, 29.912, 29.431,
       30.145, 28.775, 27.692, 30.856, 31.433, 29.213, 30.901, 30.529, 28.33, 29.793,
       30.006, 30.841, 31.762, 30.591, 30.305, 30.872, 29.23, 30.43, 30.468, 31.226, 29.77,
       29.016, 28.899, 29.786, 31.599, 28.976, 30.78, 28.972, 29.919, 29.092, 31.308,
       31.128, 30.596, 28.966, 31.16, 28.825, 30.75, 28.252, 29.317, 29.998, 29.424
       , 29.629, 29.211, 31.043, 31.487, 29.683, 29.828, 31.349, 31.427, 30.067, 30.126
       , 29.149, 29.452, 29.215, 28.047, 29.566, 30.016, 30.517, 28.904, 28.883, 29.591
       , 30.387, 28.956, 38, 39)
outliers <- c(1, 2, 19, 21, 38, 39)

draw.data("step1")

p <- ggplot(data.frame(x), aes(x)) + geom_density(bw = 0.2)
p + xlim(0, 40) + geom_vline(xintercept = 20, col = cbRed, size = 2)
ggsave_nice("step2")

p1 <- p + xlim(0, 20) +
  geom_rug(data = data.frame(x = x), aes(x), col = cbGrey) +
  geom_rug(data = data.frame(x = outliers), aes(x), col = cbRed, size = 2) +
  geom_vline(data = data.frame(x = doubleMadFences(x[x < 20])), aes(xintercept = x), col = cbRed, linetype = "dashed")
p2 <- p + xlim(20, 40) +
  geom_rug(data = data.frame(x = x), aes(x), col = cbGrey) +
  geom_rug(data = data.frame(x = outliers), aes(x), col = cbRed, size = 2) +
  geom_vline(data = data.frame(x = doubleMadFences(x[x > 20])), aes(xintercept = x), col = cbRed, linetype = "dashed")
ggsave_nice2("step3", list(p1, p2))

draw(x) + theme_bw()
draw(x)
ggsave_nice("step4")

#set.seed(42)
#n <- 100
#x <- c(1, 7, rnorm(n, 10), 13, 19, 20, 21, 27, rnorm(n, 30), 33, 38, 39)
#draw(x)
#ggsave_nice("outliers2")

