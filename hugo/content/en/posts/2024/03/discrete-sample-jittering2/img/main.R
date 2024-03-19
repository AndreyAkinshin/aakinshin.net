# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Functions --------------------------------------------------------------------
library(ggplot2) # Plotting
library(Hmisc)   # Harrell-Davis quantile estimator

StatQDensity <- ggproto("StatQDensity", Stat,
                        compute_group = function(data, scales, bincount, Q) {
                          # Transforming the input data$x to QRDE-HD
                          p <- seq(0, 1, length.out = bincount + 1)
                          q <- Q(data$x, p)
                          h <- pmax(1 / bincount / (tail(q, -1) - head(q, -1)), 0)
                          den_x <- rep(q, each = 2)
                          den_y <- c(0, rep(h, each = 2), 0)
                          data.frame(x = den_x, y = den_y)
                        }
)

#' @param bincount the number of bins in the pseudo-histogram
#' @param Q the target quantile estimator (default: Harrell-Davis)
geom_qrdensity <- function(mapping = NULL, data = NULL,
                           stat = "qdensity", position = "identity",
                           bincount = 1000, Q = hdquantile, ...) {
  layer(
    stat = StatQDensity,
    data = data,
    mapping = mapping,
    geom = GeomLine,
    position = position,
    params = list(bincount = bincount, Q = Q, ...),
  )
}

#' @param x sample
#' @param s resolution of the measurements
jitter <- function(x, s) {
  x <- sort(x)
  n <- length(x)
  # Searching for intervals [i;j] of tied values
  i <- 1
  while (i <= n) {
    j <- i
    while (j < n && x[j + 1] - x[i] < s / 2) {
      j <- j + 1
    }
    if (i < j && j - i + 1 < n) {
      k <- j - i + 1
      u <- 0:(k - 1) / (k - 1)
      xi <- u - 0.5
      if (i == 1)
        xi <- u / 2
      if (j == n)
        xi <- (u - 1) / 2
      if (i == 1 && j == n)
        xi <- u - 0.5
      x[i:j] <- x[i:j] + xi * s
      
    }
    i <- j + 1
  }
  return(x)
}

draw_densities <- function(df, names = c()) {
  colors <- c(
    "QRDE-HD" = cbp$green,
    "QRDE-THD" = cbp$orange,
    "QRDE-HF7" = cbp$pink,
    "KDE" = cbp$blue,
    "Histogram" = cbp$red
  )
  if (is.numeric(df))
    df <- data.frame(x = df)
  p <- ggplot(df, aes(x))
  for (name in names) {
    if (name == "QRDE-HD")
      p <- p + geom_qrdensity(aes(color = "QRDE-HD"), linewidth = 1.1)
    if (name == "QRDE-THD")
      p <- p + geom_qrdensity(aes(color = "QRDE-THD"), linewidth = 1.1,
                              Q = thdquantile)
    if (name == "QRDE-HF7")
      p <- p + geom_qrdensity(aes(color = "QRDE-HF7"), Q = quantile)
    if (name == "KDE")
      p <- p + geom_density(aes(color = "KDE"))
    if (name == "Histogram")
      p <- p + geom_histogram(aes(color = "Histogram", y = after_stat(density)),
                              fill = "transparent", bins = 30)
  }
  p <- p +
    geom_rug(sides = "b", linewidth = 1.1) +
    scale_color_manual(values = colors) +
    labs(color = "") +
    theme(
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "bottom",
      strip.text = element_text(hjust = 0)
    )
  if (any(names(df) == "type"))
    p <- p + facet_wrap(vars(type), ncol = 1, scales = "free")
  p
}


# Figures ----------------------------------------------------------------------
figure_discretization <- function() {
  set.seed(1729)
  n <- 2000
  x0 <- round(rnorm(n), 1)
  
  x <- round(x0, 1)
  df <- data.frame(type = "n = 2000; Norm(0, 1)", n, x)
  p1 <- draw_densities(df, c("KDE", "QRDE-HD")) +
    coord_cartesian(xlim = c(-2.5, 2.5)) +
    scale_x_continuous(breaks = seq(-2.5, 2.5, by = 0.5))
  
  x <- round(x0 / 5, 1)
  df <- data.frame(type = "n = 2000; Norm(0, 0.2^2)", n, x)
  p2 <- draw_densities(df, c("KDE")) +
    coord_cartesian(xlim = c(-0.5, 0.5)) +
    scale_x_continuous(breaks = seq(-0.5, 0.5, by = 0.1))
  grid.arrange(p1, p2, nrow = 2)
}

figure_jittering <- function() {
  set.seed(1729)
  x <- rnorm(2000)
  xr <- round(x, 1)
  xj <- jitter(xr, 0.1)
  df <- rbind(
    data.frame(type = "(a) Original", x = x, type_d = "(d) Original vs. Jittered"),
    data.frame(type = "(b) Rounded", x = xr, type_d = ""),
    data.frame(type = "(c) Jittered", x = xj, type_d = "(d) Original vs. Jittered")
  )
  p1 <- ggplot(df, aes(x, col = type)) +
    facet_wrap(vars(type), nrow = 1) +
    geom_qrdensity() +
    geom_rug(sides = "b") +
    scale_color_manual(values = c(cbp$orange, cbp$red, cbp$green)) +
    scale_x_continuous(breaks = -3:3) +
    labs(x = "") +
    theme(legend.position = "none")
  p2 <- ggplot(df[df$type != "(b) Rounded",], aes(x, col = type)) +
    facet_wrap(vars(type_d)) +
    geom_qrdensity() +
    scale_color_manual(values = c(cbp$orange, cbp$green)) +
    scale_x_continuous(breaks = -3:3) +
    theme(legend.position = "none")
  grid.arrange(p1, p2, nrow = 2)
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
