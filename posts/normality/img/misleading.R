library(ggplot2)
library(tidyr)
library(scales)
library(gridExtra)

set.seed(42)
n <- 100
a <- sample(c(100 + rbeta(n, 1, 10) * 20, 100 + rbeta(n, 1, 10) * 800), n)
b <- sample(120 + rbeta(n, 1, 5) * 80, n)

sf <- function(m, label) stat_function(
  fun = dnorm,
  args = list(mean = m, sd = 0.5),
  geom = "area",
  alpha = 0.4,
  aes(fill = label, colour = label))
p1 <- ggplot(data.frame(x = c(130, 140)), aes(x)) +
  sf(mean(a), "A") +
  sf(mean(b), "B") +
  scale_fill_manual("Benchmark", values = hue_pal()(2)) +
  scale_colour_manual("Benchmark", values = c("black", "black")) +
  xlab("Time, ms") +
  ylab("Density") +
  ggtitle("Expectation")

df <- data.frame(A = a, B = b) %>% gather("Benchmark", "Value", 1:2)
p2 <- ggplot(df, aes(x = Value, fill = Benchmark, group = Benchmark)) +
  geom_density(alpha = 0.4, col = "black") +
  xlim(0, 400) +
  xlab("Time, ms") +
  ylab("Density") +
  ggtitle("Reality")

# grid.arrange(p1 + theme_gray(), p2 + theme_gray(), nrow = 2)

library(ggdark)
smartsave <- function(p1, p2, filename) {
  p.light <- grid.arrange(p1 + theme_gray(), p2 + theme_gray(), nrow = 2)
  ggsave(paste0(filename, "-light.png"), p.light)
  p.dark <- grid.arrange(p1 + dark_theme_gray(), p2 + dark_theme_gray(), nrow = 2)
  ggsave(paste0(filename, "-dark.png"), p.dark)
  invert_geom_defaults()
}
smartsave(p1, p2, "misleading")

error <- function(x) {
  ci <- CI(x, 0.999)
  return((ci["upper"] - ci["lower"])/2)
}
mean(a)
mean(b)
sd(a)
sd(b)
error(a)
error(b)
median(a)
median(b)
quantile(a, c(0.1, 0.9))
quantile(b, c(0.1, 0.9))
