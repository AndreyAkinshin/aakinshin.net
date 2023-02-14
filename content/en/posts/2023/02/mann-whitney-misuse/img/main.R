# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
draw_density <- function(dDist1, dDist2, xlim) {
  x <- seq(xlim[1], xlim[2], by = 0.01)
  df <- rbind(
    data.frame(x, y = dDist1(x), type = "A"),
    data.frame(x, y = dDist2(x), type = "B")
  )
  df$type <- factor(df$type, levels = c("A", "B"))
  ggplot(df, aes(x, y, fill = type)) +
    geom_area(alpha = 0.6, position = "identity") +
    geom_line(alpha = 0) +
    scale_color_manual(values = cbp$values) +
    scale_x_continuous(breaks = pretty(xlim, 10)) +
    labs(fill = "", y = "Density")
}
draw_mw <- function(rDist1, rDist2) {
  set.seed(1729)
  n <- 5000
  ps <- replicate(500, wilcox.test(rDist1(n), rDist2(n))$p.value)
  ggplot(data.frame(x = ps), aes(x)) + 
    geom_histogram(boundary = 0, binwidth = 0.05, color = "black", fill = cbp$green) +
    geom_rug(sides = "b", col = cbp$red) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.05)) +
    labs(
      title = paste0("Histogram of p-values (count = ", n , ")"),
      x = "p-value",
      y = "Count"
    )
}

figure_density1 <- function() draw_density(
  function(x) dnorm(x),
  function(x) dnorm(x, sd = 10),
  c(-30, 30)
)

figure_mw1 <- function() draw_mw(
  function(n) rnorm(n),
  function(n) rnorm(n, sd = 10)
)

figure_density2 <- function() draw_density(
  function(x) dunif(x, -1, 1),
  function(x) (dunif(x, -3, -2) + dunif(x, 2, 3)) / 2,
  c(-3, 3)
)

figure_mw2 <- function() draw_mw(
  function(n) runif(n, -1, 1),
  function(n) ifelse(sample(0:1, n, TRUE), runif(n, -3, -2), runif(n, 2, 3))
)

figure_density3 <- function() draw_density(
  function(x) 0.51 * dunif(x, 0, 1) + 0.49 * dunif(x, 10, 11),
  function(x) 0.49 * dunif(x, 2, 3) + 0.51 * dunif(x, 8, 9),
  c(0, 11)
) + geom_vline(xintercept = c(50 / 51, 8 + 1 / 51), col = cbp$values[1:2], size = 2)

figure_mw3 <- function() draw_mw(
  function(n) ifelse(sample(1:100, n, TRUE) < 51, runif(n, 0, 1), runif(n, 10, 11)),
  function(n) ifelse(sample(1:100, n, TRUE) < 49, runif(n, 2, 3), runif(n, 8, 9))
)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
