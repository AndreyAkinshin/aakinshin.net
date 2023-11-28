# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Functions --------------------------------------------------------------------
draw_ts <- function(start = 1) {
  set.seed(1729)
  mean1 <- 10
  mean2 <- 40

  n <- 1000
  x <- 1:n
  y <- rnorm(n, mean1)
  z <- rep(FALSE, n)
  z[c(57:59, 321:323, 754:756, 876:878, 998:1000)] <- TRUE
  y[z] <- rnorm(sum(z), mean2)

  df <- data.frame(x, y, z)
  df <- df[df$x >= start,]
  ggplot(df, aes(x, y, col = z, shape = z)) +
    geom_point() +
    scale_color_manual(values = c(cbp$green, cbp$red)) +
    scale_y_continuous(limits = c(0, NA), breaks = seq(0, mean2, by = 5)) +
    labs(x = "Iteration", y = "Measurement") +
    guides(color = FALSE, shape = FALSE)
}

# Figures ----------------------------------------------------------------------
figure_ts1 <- function() draw_ts(901)
figure_ts2 <- function() draw_ts(1)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
