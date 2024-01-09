library(ggplot2)
library(latex2exp)
library(ggdark)
smartsave <- function(p, filename) {
  ggsave(paste0(filename, "-light.png"), p + theme_gray())
  ggsave(paste0(filename, "-dark.png"), p + dark_theme_gray())
}


stat_function_fill <- function(fill, xlim)
  stat_function(fun = dnorm, geom = "area", fill = fill, alpha = 0.25, xlim = xlim)

geom_vsegm <- function(x0, linetype = "dashed")
  geom_segment(aes(x = x0, y = 0, xend = x0, yend = dnorm(x0)), linetype = linetype)

ticks <- c(
  TeX("$\\bar{x}-4s$"),
  TeX("$\\bar{x}-3s$"),
  TeX("$\\bar{x}-2s$"),
  TeX("$\\bar{x}-1s$"),
  TeX("$\\bar{x}$"),
  TeX("$\\bar{x}+1s$"),
  TeX("$\\bar{x}+2s$"),
  TeX("$\\bar{x}+3s$"),
  TeX("$\\bar{x}+4s$"))

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm) +
  stat_function_fill("#E69F00", c(-3, -2)) +
  stat_function_fill("#56B4E9", c(-2, -1)) +
  stat_function_fill("#CC79A7", c(-1, +1)) +
  stat_function_fill("#56B4E9", c(+1, +2)) +
  stat_function_fill("#E69F00", c(+2, +3)) +
  labs(x = "", y = "", title = "Normal Distribution") +
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
  scale_x_continuous(breaks = c(-4:4), labels = ticks) +
  scale_y_continuous(expand = c(0, 0))

smartsave(p, "normal")
