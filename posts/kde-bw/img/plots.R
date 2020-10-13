library(ggplot2)
library(ggdark)
library(svglite)
library(gridExtra)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 2)

save <- function(name, plot = last_plot(), tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), plot + theme_gray() + tm, width = 8, height = 6)
  ggsave(paste0(tolower(name), "-dark.svg"), plot + dark_theme_gray() + tm, width = 8, height = 6)
  invert_geom_defaults()
}

save2 <- function(name, p1, p2, tm = theme(), hscale = 1.0) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(p1 + theme_gray() + tm, p2 + theme_gray() + tm, nrow = 1), width = 10, height = 6 * hscale)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(p1 + dark_theme_gray() + tm, p2 + dark_theme_gray() + tm, nrow = 1), width = 10, height = 6 * hscale)
  invert_geom_defaults()
}

save3 <- function(name, p1, p2, p3, tm = theme(), hscale = 1.0) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(
           p1 + theme_gray() + tm,
           p2 + theme_gray() + tm,
           p3 + theme_gray() + tm,
           nrow = 1),
         width = 10, height = 6 * hscale)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(
           p1 + dark_theme_gray() + tm,
           p2 + dark_theme_gray() + tm,
           p3 + dark_theme_gray() + tm,
           nrow = 1),
         width = 10, height = 6 * hscale)
  invert_geom_defaults()
}

save6 <- function(name, p1, p2, p3, p4, p5, p6, tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(
           p1 + theme_gray() + tm,
           p2 + theme_gray() + tm,
           p3 + theme_gray() + tm,
           p4 + theme_gray() + tm,
           p5 + theme_gray() + tm,
           p6 + theme_gray() + tm,
           nrow = 2),
         width = 10, height = 6)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(
           p1 + dark_theme_gray() + tm,
           p2 + dark_theme_gray() + tm,
           p3 + dark_theme_gray() + tm,
           p4 + dark_theme_gray() + tm,
           p5 + dark_theme_gray() + tm,
           p6 + dark_theme_gray() + tm,
           nrow = 2),
         width = 10, height = 6)
  invert_geom_defaults()
}

set.seed(42)
n <- 10
sd <- 1
modes <- 4
delta <- 10
x <- as.vector(sapply(1:modes, function(i) delta * (i + 1) + rnorm(n, sd = sd)))
x.min <- min(x) - delta * 2
x.max <- max(x) + delta * 2

tm <- theme(axis.title.y = element_blank(),
            axis.text.y  = element_blank(),
            axis.ticks.y = element_blank())

p <- ggplot(data.frame(x = x), aes(x)) + 
  ylab("") +
  scale_x_continuous(limits = c(x.min, x.max), breaks = seq(0, 70, by = 10))
p1 <- p + geom_density()
p2 <- p + geom_density(bw = "SJ")
grid.arrange(p1, p2, nrow = 1)
save2("kde-riddle", p1, p2, tm, 0.5)

p1 <- p + geom_density(bw = 5) + ggtitle("Oversmoothing")
p2 <- p + geom_density(bw = "SJ") + ggtitle("What we actually want")
p3 <- p + geom_density(bw = 0.0001) + ggtitle("Undersmoothing")
grid.arrange(p1, p2, p3, nrow = 1)
save3("kde-smoothing", p1, p2, p3, tm, hscale = 0.5)

p1 <- p + geom_density(bw = "nrd0") + ggtitle("Silverman")
p2 <- p + geom_density(bw = "nrd") + ggtitle("Scott")
p3 <- p + geom_density(bw = "bcv") + ggtitle("Biased cross-validation")
p4 <- p + geom_density(bw = "ucv") + ggtitle("Unbiased cross-validation")
p5 <- p + geom_density(bw = "SJ") + ggtitle("Sheather & Jones")
p6 <- p + geom_density(bw = 1) + ggtitle("Manual (bandwidth = 1)")
grid.arrange(p1, p2, p3, p4, p5, p6, nrow = 2)
save6("kde-comparison", p1, p2, p3, p4, p5, p6, tm)

draw.kde <- function(name, data.min, data.max, data, hs, breaks = NA) {
  build.df <- function(data, h) {
    x <- seq(data.min, data.max, length.out = 1001)
    n <- length(data)
    krn <- function(xx, i) dnorm((xx - data[i]) / h) / n / h
    df0 <- data.frame(
      x = x,
      y = sapply(1:length(x), function(j) sum(sapply(1:n, function(i) krn(x[j], i)))),
      h = paste0("h = ", h),
      group = 0,
      col = cbPalette[1],
      linetype = "dashed")
    dfi <- do.call("rbind", lapply(1:n, function(i) data.frame(
      x = x,
      y = krn(x, i),
      h = paste0("h = ", h),
      group = i,
      col = cbPalette[2],
      linetype = "solid")))
    rbind(df0, dfi)
  }
  df <- do.call("rbind", lapply(hs, function(h) build.df(data, h)))
  p <- ggplot(df, aes(x, y, group = group, col = col, linetype = linetype)) +
    geom_line() +
    facet_wrap(~ h, ncol = 3)
  if (!any(is.na(breaks)))
    p <- p + scale_x_continuous(breaks = breaks)
  tm <- theme(legend.position="none")
  save(name, p, tm)
  p
}
draw.kde("kde-build1", 0, 10, c(3, 4, 7), c(1), c(0, 3, 4, 7, 10))
draw.kde("kde-build2", 0, 10, c(3, 4, 7), c(0.2, 0.3, 0.4, 0.5, 1, 1.5), c(0, 3, 4, 7, 10))
draw.kde("kde-build3", x.min, x.max, x, c(0.1, 0.5, 1, 2, 3.5, 5), seq(0, 70, by = 10))
