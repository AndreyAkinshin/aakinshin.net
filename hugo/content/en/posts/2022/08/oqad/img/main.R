# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

Po <- 0.861678977787423
erfinv <- function(x) sqrt(qchisq(abs(x), 1) / 2) * sign(x)
qad_asymptotic_efficiency <- function(p) 2 * erfinv(p)^2 / (pi * p * (1 - p) * exp(2 * erfinv(p)^2))

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------

figure_qad_efficiency <- function() {
  step <- 0.001
  p <- seq(step, 1 - step, by = step)
  e <- qad_asymptotic_efficiency(p)
  p <- c(0, p, 1)
  e <- c(0, e, 0)
  e0 <- qad_asymptotic_efficiency(Po)
  ggplot(data.frame(p, e), aes(p, e)) +
    geom_line() +
    geom_point(x = Po, y = e0, col = cbp$navy, shape = 8) +
    labs(y = "Gaussian efficiency", title = "Asymptotic Gaussian efficiency of QAD(X, p)")
}


# Plotting ---------------------------------------------------------------------
regenerate_figures()
