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

draw.jittering <- function(x, scale = 1.5) {
  dfc <- data.frame(x) %>% dplyr::count(x, name = "cnt")
  dfc$l <- cumsum(c(0, head(dfc$cnt, -1)))
  dfc$r <- sum(dfc$cnt) - dfc$l - dfc$cnt
  noise <- unlist(
    apply(dfc, 1,
          function(u) get.noise0(u["cnt"], u["l"], u["r"])))
  x2 <- x + noise * scale
  
  p1 <- ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ", col = cbRed) +
    geom_rug(col = cbBlue) +
    xlim(min(x) - 0.5, max(x) + 0.5) +
    ggtitle("Without jittering") +
    labs(x = "")
  p2 <- ggplot(data.frame(x = x2), aes(x)) +
    geom_density(bw = "SJ", col = cbRed) +
    geom_rug(col = cbBlue) +
    xlim(min(x) - 0.5, max(x) + 0.5) +
    ggtitle("With jittering") +
    labs(x = "")
  p1 | p2
}

draw.kde <- function(x) {
  ggplot(data.frame(x), aes(x)) +
    geom_density(bw = "SJ", col = cbRed) +
    geom_rug(col = cbBlue) +
    scale_x_continuous(limits = c(0, 50), breaks = seq(0, 100, by = 10)) +
    labs(
      title = paste0("Kernel density estimation (discrete distribution, N = ", length(x), ")"),
      x = "duration, ms")
}

set.seed(42)
x <- pmax(round(rgumbel(3000, 20, 5)), 0)
draw.kde(x)
ggsave_nice("intro")

draw.kde(head(x, 2500))
ggsave_nice("problem1")
draw.kde(head(x, 2600))
ggsave_nice("problem2")

draw.jittering(x)
ggsave_nice("comparison")

dfb <- expand.grid(a = 1:9, x = seq(0, 1, by = 0.01)) %>%
  mutate(b = 10 - a) %>% 
  mutate(y = dbeta(x, a, b)) %>% 
  mutate(title = paste0("a = ", a, ", b = ", b))
ggplot(dfb, aes(x, y)) +
  facet_wrap(vars(title), scales = "free") +
  scale_x_continuous(expand = c(0, 0)) +
  geom_line(col = cbGreen) + 
  theme(
    axis.ticks.y = element_blank(),
    axis.text.y = element_blank()
    ) +
  labs(title = "Noise patterns (beta distribution)", y = "density")
ggsave_nice("noise-patterns")

set.seed(42)
x <- rbinom(1000, 30, 0.2)
draw.jittering(x)
ggsave_nice("jittering-demo1")

set.seed(42)
x <- c(rbinom(1000, 20, 0.2), rbinom(1000, 20, 0.8))
draw.jittering(x)
ggsave_nice("jittering-demo2")
