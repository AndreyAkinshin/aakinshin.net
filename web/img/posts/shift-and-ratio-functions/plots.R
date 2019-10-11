library(ggplot2)
library(gridExtra)
library(ggdark)
library(Hmisc)
library(tidyr)

gen.multimodal <- function(mu1, mu2, sd = 3) sample(
  c(mu1 + rbeta(300, 1, 10) * 26 * sd + rnorm(300, sd = sd),
    mu2 + rbeta(700, 1, 10) * 26 * sd + rnorm(700, sd = sd))
)
gen.multimodal3 <- function(mu1, mu2, mu3, sd = 3) sample(
  c(mu1 + rbeta(300, 1, 10) * 26 * sd + rnorm(300, sd = sd),
    mu2 + rbeta(400, 1, 10) * 26 * sd + rnorm(400, sd = sd),
    mu3 + rbeta(300, 1, 10) * 26 * sd + rnorm(300, sd = sd))
)

build.timeline <- function(index, a, b, filename, shift = FALSE) {
  data <- c(a, b)
  lims <- extendrange(data, f = 0.1)
  p1 <- ggplot(data.frame(x = 1:length(data), y = data), aes(x = x, y = y)) +
    geom_point() +
    ggtitle(paste0("Timeline (Case ", index, ")")) +
    xlab("Iteration") +
    ylab("Duration")
  p2 <- ggplot(data.frame(x = a), aes(x = x)) +
    geom_density(bw = "SJ", alpha = .2, fill = "#FF6666") +
    xlim(lims) +
    ggtitle("Before") +
    xlab("Duration") +
    ylab("Density")
  p3 <- ggplot(data.frame(x = b), aes(x = x)) +
    geom_density(bw = "SJ", alpha = .2, fill = "#FF6666") +
    ggtitle("After") +
    xlim(lims) +
    xlab("Duration") +
    ylab("Density")

  if (shift) {
    probs <- seq(0.1, 0.9, by = 0.01)
    df <- data.frame(
      Quantiles = probs,
      Shift = hdquantile(b, probs) - hdquantile(a, probs)
    )
    p4 <- ggplot(df, aes(x = Quantiles, y = Shift)) +
      geom_hline(yintercept = 0, col = "darkblue") +
      geom_line(col = "darkgreen") +
      ggtitle("Shift function")

    p234.light <- grid.arrange(p2 + theme_gray(), p3 + theme_gray(), p4 + theme_gray(), nrow = 3)
    p.light <- grid.arrange(p1 + theme_gray(), p234.light, ncol = 2)
    ggsave(paste0(filename, "-light.png"), p.light, width = 9, height = 9)

    p234.dark <- grid.arrange(p2 + dark_theme_gray(), p3 + dark_theme_gray(), p4 + dark_theme_gray(), nrow = 3)
    p.dark <- grid.arrange(p1 + dark_theme_gray(), p234.dark, ncol = 2)
    ggsave(paste0(filename, "-dark.png"), p.dark, width = 9, height = 9)
  } else {
    p23.light <- grid.arrange(p2 + theme_gray(), p3 + theme_gray(), nrow = 2)
    p.light <- grid.arrange(p1 + theme_gray(), p23.light, ncol = 2)
    ggsave(paste0(filename, "-light.png"), p.light, width = 9, height = 9)

    p23.dark <- grid.arrange(p2 + dark_theme_gray(), p3 + dark_theme_gray(), nrow = 2)
    p.dark <- grid.arrange(p1 + dark_theme_gray(), p23.dark, ncol = 2)
    ggsave(paste0(filename, "-dark.png"), p.dark, width = 9, height = 9)
  }
  invert_geom_defaults()
}

build.quantiles <- function(a1, b1, a2, b2, a3, b3, name, func, baseline) {
  probs <- seq(0.1, 0.9, by = 0.01)

  df <- data.frame(
    Quantiles = probs,
    Case1 = func(hdquantile(a1, probs), hdquantile(b1, probs)),
    Case2 = func(hdquantile(a2, probs), hdquantile(b2, probs)),
    Case3 = func(hdquantile(a3, probs), hdquantile(b3, probs))
  ) %>% gather("Case", "Value", 2:4)


  p <- ggplot(df, aes(x = Quantiles, y = Value, group = Case)) +
    geom_hline(yintercept = baseline, col = "darkblue") +
    #geom_point() +
    geom_line(col = "darkgreen") +
    facet_grid(. ~ Case) +
    ggtitle(paste0(name, " functions")) +
    ylab(name)
  ggsave(paste0(tolower(name), "-light.png"), p + theme_gray(), width = 8, height = 6)
  ggsave(paste0(tolower(name), "-dark.png"), p + dark_theme_gray(), width = 8, height = 6)
  invert_geom_defaults()
}

set.seed(42)
a1 <- rnorm(1000, 120, 10)
b1 <- rnorm(1000, 150, 10)
a2 <- gen.multimodal(20, 250)
b2 <- gen.multimodal(40, 250)
a3 <- gen.multimodal(20, 250)
b3 <- gen.multimodal(40, 210)
a4 <- gen.multimodal3(20, 100, 250)
b4 <- gen.multimodal3(20, 150, 250)
a5 <- gen.multimodal(100, 200, sd = 7)
b5 <- gen.multimodal3(50, 130, 250, sd = 12)
a6 <- a5
b6 <- gen.multimodal3(50, 170, 250, sd = 20)
build.timeline(1, a1, b1, "compare1")
build.timeline(2, a2, b2, "compare2")
build.timeline(3, a3, b3, "compare3")
build.timeline(4, a4, b4, "compare4", shift = TRUE)
build.timeline(5, a5, b5, "compare5", shift = TRUE)
build.timeline(6, a6, b6, "compare6", shift = TRUE)
build.quantiles(a1, b1, a2, b2, a3, b3, "Shift", function(qa, qb) qb - qa, 0.0)
build.quantiles(a1, b1, a2, b2, a3, b3, "Ratio", function(qa, qb) qb / qa, 1.0)
