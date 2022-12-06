# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------

draw_exp <- function(phase) {
  set.seed(1729)
  data <- data.frame(x = rexp(100))
  titles <- list(tr = "True distribution", unbnd = "Unbounded KDE", bnd = "Bounded KDE")
  p <- ggplot(data, aes(x)) +
    stat_function(aes(colour = titles$tr), fun = dexp, n = 1001) + 
    geom_density(aes(colour = titles$unbnd), key_glyph = "path", bw = "SJ") +
    scale_colour_manual(name = NULL, values = cbp$values, breaks = titles) +
    xlim(-2, NA) +
    labs(x = "x", y = "Density")
  if (phase == 1)
    return(p)
  
  p <- p + geom_density(aes(colour = titles$bnd), bounds = c(0, Inf), key_glyph = "path")
  if (phase == 2)
    return(p)
  
  stop("Unknown phase: ", phase)
}

draw_unif <- function(phase) {
  set.seed(42)
  data <- runif(1000)
  L <- 0
  R <- 1
  den1 <- density(data, bw = "SJ")
  den1_approx <- approxfun(
    x = den1$x, y = den1$y, method = "linear"
  )
  den1_center <- data.frame(x = den1$x[den1$x >= L & den1$x <= R], y = den1$y[den1$x >= L & den1$x <= R])
  
  if (phase == 1) {
    p <- ggplot(data.frame(x = den1$x, y = den1$y), aes(x, y)) +
      geom_line(col = cbp$red) +
      geom_vline(xintercept = c(L, R), col = cbp$grey) +
      scale_x_continuous(limits = c(-0.2, 1.2), breaks = seq(-0.2, 1.2, by = 0.1)) +
      ylab("Density")
    return(p + ggtitle("Unbounded KDE"))
  }
  
  den2 <- den1
  den2$x[den2$x < L] <- L + (L - den2$x[den2$x < L])
  den2$x[den2$x > R] <- R - (den2$x[den2$x > R] - R)
  ar <- arrow(length = unit(0.5, "cm"))
  
  if (phase == 2) {
    df_arrow <- data.frame(
      x = c(-0.05, 1.05),
      xend = c(0.05, 0.95),
      y = c(den1_approx(-0.05), den1_approx(1.05)),
      yend = c(den1_approx(-0.05), den1_approx(1.05))
    )
    
    p <- ggplot() +
      geom_path(data = data.frame(x = den2$x, y = den2$y), aes(x, y), col = cbp$green) +
      geom_line(data = den1_center, aes(x, y), col = cbp$red) +
      geom_line(data = data.frame(x = den1$x, y = den1$y), aes(x, y), col = cbp$red, linetype = "dashed") +
      geom_segment(data = df_arrow, aes(x, y, xend = xend, yend = yend), arrow = ar, col = cbp$blue) +
      geom_vline(xintercept = c(L, R), col = cbp$grey) +
      scale_x_continuous(limits = c(-0.2, 1.2), breaks = seq(-0.2, 1.2, by = 0.1)) +
      ylab("Density")
    return(p + ggtitle("Step 1: Reflecting the tails"))
  }
  
  if (phase == 3) {
    df_arrow <- data.frame(
      x = c(head(den2$x, 1), tail(den2$x, 1)),
      xend = c(head(den2$x, 1), tail(den2$x, 1)),
      y = c(0, 0),
      yend = c(den1_approx(head(den2$x, 1)), den1_approx(tail(den2$x, 1)))
    )
    p <- ggplot() +
      geom_path(data = data.frame(x = den2$x, y = den2$y), aes(x, y), col = cbp$green, linetype = "dashed") +
      geom_line(data = data.frame(x = den1$x, y = den1$y), aes(x, y), col = cbp$red, linetype = "dashed") +
      geom_density(data = data.frame(x = data), aes(x), bounds = c(L, R), col = cbp$red, bw = "SJ") +
      geom_segment(data = df_arrow, aes(x, y, xend = xend, yend = yend), arrow = ar, col = cbp$blue) +
      geom_vline(xintercept = c(L, R), col = cbp$grey) +
      scale_x_continuous(limits = c(-0.2, 1.2), breaks = seq(-0.2, 1.2, by = 0.1)) +
      ylab("Density")
    return(p + ggtitle("Step 2: Summation"))
  }
  
  stop("Unknown phase: ", phase)
}

# Figures ----------------------------------------------------------------------

figure_exp1 <- function() draw_exp(1)
figure_exp2 <- function() draw_exp(2)
figure_unif1 <- function() draw_unif(1)
figure_unif2 <- function() draw_unif(2)
figure_unif3 <- function() draw_unif(3)

# Plotting ---------------------------------------------------------------------

regenerate_figures()