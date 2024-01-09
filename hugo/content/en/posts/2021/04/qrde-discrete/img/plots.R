library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)
library(stringr)
library(evd)
library(patchwork)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 200) {
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

# QRDE
qrde.df <- function(x, step) {
  probs <- seq(0, 1, by = step)
  q <- hdquantile(x, probs)
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
  return(data.frame(x, y))
}
draw.qrde <- function(x, step = 0.01) {
  df <- qrde.df(x, step)
  ggplot(df, aes(x, y)) +
    geom_line(col = cbPalette[1]) +
    ggtitle(paste0("QRDE (k = ", 1 / step, ")")) +
    geom_rug(data = data.frame(x, y = 0), aes(x, y), col = cbBlue, sides = "b") +
    theme(plot.title = element_text(hjust = 0.5))
}

### Jittering
jittering <- function(x, scale = 1.5) {
  get.noise <- function(k, l, r) {
    if (k == 1 || l + r == 0)
      return(0)
    a <- (9 * l + r) / (l + r)
    b <- (l + 9 * r) / (l + r)
    m <- (a - 1) / (a + b - 2)
    p <- 1:k / (k+1)
    p0 <- p[which.min(abs(m - p))]
    q0 <- qbeta(p0, a, b)
    q <- qbeta(p, a, b) - q0
    q
  }

  dfc <- data.frame(x) %>% dplyr::count(x, name = "cnt")
  dfc$l <- cumsum(c(0, head(dfc$cnt, -1)))
  dfc$r <- sum(dfc$cnt) - dfc$l - dfc$cnt
  noise <- unlist(
    apply(dfc, 1,
          function(u) get.noise(u["cnt"], u["l"], u["r"])))
  sort(x) + noise * scale
}

### Gumbel

g.from <- -2.5
g.to <- 7.5
x <- seq(g.from, g.to, by = 0.01)
y <- dgumbel(x)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  labs(title = "PDF (Gumbel)", x = "x", y = "density")
ggsave_nice("gumbel-pdf")

x <- seq(g.from, g.to, by = 0.01)
y <- pgumbel(x)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  labs(title = "CDF (Gumbel)", x = "x", y = "p")
ggsave_nice("gumbel-cdf")

x <- seq(pgumbel(g.from), pgumbel(g.to), length.out = 1001)
y <- qgumbel(x)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  labs(title = "Quantile (Gumbel)", x = "p", y = "x")
ggsave_nice("gumbel-quantile")

### Poisson
lambda <- 1

p.from <- 0
p.to <- 5
x <- seq(p.from, p.to, by = 1)
y <- dpois(x, lambda)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_bar(stat = "identity", fill = cbRed) +
  labs("PMF (Poisson)", x = "x", y = "density") +
  scale_x_continuous(breaks = x)
ggsave_nice("poisson-pmf")

x <- seq(p.from, p.to, by = 1)
y <- ppois(x, lambda)
ggplot(data.frame(x, y, py = c(0, head(y, -1))), aes(x, y)) +
  geom_segment(aes(xend = x + 1, yend = y), col = cbRed) +
  geom_segment(aes(xend = x, yend = py), col = cbRed, linetype = "dashed") +
  geom_point(col = cbRed) +
  scale_x_continuous(breaks = x, limits = c(0, 5)) +
  scale_y_continuous(breaks = 0:10/10, limits = c(0, 1)) +
  labs(title = "CDF (Poisson)", x = "x", y = "p")
ggsave_nice("poisson-cdf")

x <- seq(0, ppois(p.to, lambda), length.out = 1001)
y <- qpois(x, lambda)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(col = cbRed, size = 0.2) +
  geom_line(linetype = "dashed", col = cbRed) +
  scale_x_continuous(breaks = 0:10/10) +
  scale_y_continuous(breaks = 0:6) +
  labs(title = "Quantile (Poisson)", x = "p", y = "x")
ggsave_nice("poisson-quantile")

x <- seq(p.from, p.to, by = 1)
y <- dpois(x, lambda)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_segment(aes(xend = x, yend = 0), col = cbRed) +
  geom_point(col = cbRed, shape = 17, size = 3) +
  scale_x_continuous(breaks = x) +
  labs(title = "PDF (Poisson)", y = "density")
ggsave_nice("poisson-pdf")

set.seed(43)
x <- rnorm(100)
draw.qrde(x)
ggsave_nice("norm-qrde")

#set.seed(3)
#x <- rpois(15, lambda)
x <- c(0, 2, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 2)
draw.qrde(x)
ggsave_nice("poisson-qrde1")

draw.qrde(c(x, 0))
ggsave_nice("poisson-qrde2")

draw.qrde(c(x, 0, 0))
ggsave_nice("poisson-qrde3")

draw.qrde(jittering(c(x, 0, 0)))
ggsave_nice("poisson-qrde4")
