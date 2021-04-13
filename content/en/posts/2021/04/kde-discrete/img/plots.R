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

x <- c(3.82, 4.61, 4.89, 4.91, 5.31, 5.6, 5.66, 7, 7, 7)
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ", col = cbRed) +
  geom_rug(col = cbBlue) +
  xlim(2, 9)
ggsave_nice("intro")

### Exponential

x <- seq(0, 5, by = 0.01)
y <- dexp(x)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  ggtitle("PDF (Exponential)")
ggsave_nice("exp-pdf")

### Poisson
lambda <- 1

x <- seq(0, 6)
y <- dpois(x, lambda)
ggplot(data.frame(x, y), aes(x, y)) +
  geom_bar(stat = "identity", fill = cbRed) +
  labs("PMF (Poisson)", x = "x", y = "density") +
  scale_x_continuous(breaks = x)
ggsave_nice("poisson-pmf")

x <- c(2, 3, 0, 2, 1, 1, 2, 0, 1, 1)
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ", col = cbRed) +
  xlim(-0.5, 4) +
  labs(title = "KDE (Poisson)")
ggsave_nice("poisson-kde")

ggplot(data.frame(x) %>% count(), aes(x, freq)) +
  geom_segment(aes(xend = x, yend = 0), col = cbRed) +
  geom_point(col = cbRed, shape = 17, size = 3) +
  ylim(0, 4) +
  labs(title = "PDF (Poisson)", y = "")
ggsave_nice("poisson-pdf")

x <- seq(-3, 3, by = 0.01)
y <- dnorm(x)
p1 <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  ggtitle("Gaussian") +
  xlim(-3, 3) + ylim(0, 1)

y[x < 0] <- 0
p2 <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  geom_segment(x = 0, y = 0, xend = 0, yend = 1, col = cbRed) +
  geom_point(x = 0, y = 1, shape = 17, col = cbRed, size = 3) +
  annotate("text", x = 0, y = 0.95, hjust = -0.3, label = "0.5", col = cbRed) +
  ggtitle("Rectified Gaussian") +
  xlim(-3, 3) + ylim(0, 1)

y <- y * 2
p3 <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_line(col = cbRed) +
  ggtitle("Truncated Gaussian") +
  xlim(-3, 3) + ylim(0, 1)

p1 | p2 | p3
ggsave_nice("rectified-pdf")

set.seed(42)
x <- pmax(round(rgumbel(3000, 20, 5)), 0)
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ", col = cbRed) +
  geom_rug(col = cbBlue) +
  scale_x_continuous(limits = c(0, 50), breaks = seq(0, 100, by = 10)) +
  labs(title = "KDE, N = 3000", x = "duration, ms")
ggsave_nice("real-pdf")

set.seed(42)
x <- rnorm(500)
x[x < 0] <- 0
ggplot(data.frame(x), aes(x)) +
  geom_density(bw = "SJ", col = cbRed) +
  geom_rug(col = cbBlue) +
  labs(title = "KDE, Rectified Gaussian, N=500")
ggsave_nice("real2-pdf")
