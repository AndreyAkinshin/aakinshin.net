library(ggplot2)
library(ggdark)
library(svglite)
library(gridExtra)

source("../src/weighted-quantiles.R")

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 2)

save <- function(name, plot = last_plot(), tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), plot + theme_gray() + tm, width = 8, height = 6)
  ggsave(paste0(tolower(name), "-dark.svg"), plot + dark_theme_gray() + tm, width = 8, height = 6)
  invert_geom_defaults()
}

save2 <- function(name, p1, p2) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(p1 + theme_gray(), p2 + theme_gray(), nrow = 1), width = 10, height = 6)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(p1 + dark_theme_gray(), p2 + dark_theme_gray(), nrow = 1), width = 10, height = 6)
  invert_geom_defaults()
}

buildHd <- function(name, n, p, points = c()) {
  a <- p * (n + 1)
  b <- (1 - p) * (n + 1)
  f <- function(t) t ^ (a-1) * (1 - t) ^ (b - 1)

  mainCurve <- function() {
    x <- seq(0, 1, by = 0.001)
    y <- f(x)
    df <- data.frame(x, y)
    geom_line(data = data.frame(x, y), mapping = aes(x, y))
  }
  area <- function(x1, x2, fill) {
    x <- c(seq(x1, x2, by = 0.001))
    y <- f(x)
    xp <- c(x1, x, x2)
    yp <- c(0, y, 0)
    geom_polygon(data = data.frame(x = xp, y = yp), mapping = aes(x, y), fill = fill, alpha = 0.5, col = NA)
  }
  tm <- theme(axis.title.y = element_blank(),
              axis.text.y  = element_blank(),
              axis.ticks.y = element_blank())
  
  pl <- ggplot()
  if (length(points) > 1)
    for (i in 1:(length(points) - 1))
      pl <- pl + area(points[i], points[i + 1], cbPalette[i])
  pl <- pl + mainCurve() + xlab("t") + scale_x_continuous(breaks = seq(0, 1, by = 0.2))
  save(paste0("hd", name), pl, tm)
}

buildType7 <- function(name, n, p, points = c()) {
  h <- p * (n - 1) + 1
  l <- (h - 1) / n
  r <- h / n
  x <- seq(0, 1, by = 0.001)
  f <- Vectorize(function(u) {
    if (u < l || u > r)
      return(0)
    return(n)
  })
  F <- Vectorize(function(u) {
    if (u < l)
      return(0)
    if (u > r)
      return(1)
    return(u * n - h + 1)
  })
  area <- function(x1, x2, func, fill) {
    x <- c(seq(x1, x2, by = 0.001))
    y <- func(x)
    xp <- c(x1, x, x2)
    yp <- c(0, y, 0)
    geom_polygon(data = data.frame(x = xp, y = yp), mapping = aes(x, y), fill = fill, alpha = 0.5, col = NA)
  }
  
  pdf <- ggplot() +
    geom_line(data = data.frame(x = x, y = f(x)), mapping = aes(x, y)) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.2)) + 
    ggtitle("PDF")
  cdf <- ggplot() +
    geom_line(data = data.frame(x = x, y = F(x)), mapping = aes(x, y)) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.2)) +
    ggtitle("CDF")
  
  if (length(points) > 1)
    for (i in 1:(length(points) - 1)) {
      pdf <- pdf + area(points[i], points[i + 1], f, cbPalette[i])
      cdf <- cdf + area(points[i], points[i + 1], F, cbPalette[i])
    }
  
  save2(paste0("type7-", name), pdf, cdf)
}

buildAdaptiveMedian <- function(phase) {
  time <- 1:100
  set.seed(42)
  values <- c(
    20 + rnorm(50),
    40 + rnorm(30),
    30 + rnorm(20)
  )
  lifetime <- 5
  weights <- exp(-(time - 1) / lifetime * log(2))
  medians <- sapply(time, function(k) whdquantile(values[1:k], 0.5, rev(weights[1:k])))
  pl <- ggplot() +
    geom_point(data = data.frame(x = time, y = values), mapping = aes(x, y)) +
    xlab("Day") + ylab("Duration")
  if (phase == "2")
    pl <- pl +
    geom_line(data = data.frame(x = time, y = medians), mapping = aes(x, y), col = cbPalette[2], size = 1.5)
  save(paste0("moving", phase), pl)
}

buildHd("1", 9, 0.25)
buildHd("2", 9, 0.25, c(0, 0.25))
buildHd("3", 9, 0.25, (0:9)/9)
buildHd("4", 5, 0.5, (0:5)/5)
buildHd("5", 5, 0.5, (0:3)/3)
buildHd("6", 5, 0.5, c(0, 0.4, 0.8, 0.85, 0.90, 1))

buildType7("1", 5, 0.25)
buildType7("2", 5, 0.25, c(0.2, 0.4))
buildType7("3", 5, 0.35, c(0.2, 0.4, 0.6))

buildAdaptiveMedian("1")
buildAdaptiveMedian("2")
