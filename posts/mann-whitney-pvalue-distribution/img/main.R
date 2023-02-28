# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
draw_hist <- function(x) {
  ggplot(data.frame(x), aes(x)) +
    geom_histogram(binwidth = 0.01, boundary = 0, fill = cbp$red, alpha = 0.5) +
    geom_histogram(binwidth = 0.01, boundary = 0, fill = "transparent", col = cbp$red) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
    labs(x = "p-value", y = "Count")
}

figure_t <- function() {
  set.seed(1729)
  x <- replicate(10000, t.test(rnorm(5), rnorm(5))$p.value)
  draw_hist(x) +
    ylim(0, 500) +
    ggtitle("Student's t-test, n = 5")
}

draw_mw <- function(n) {
  set.seed(1729)
  x <- replicate(10000, wilcox.test(rnorm(n), rnorm(n))$p.value)
  draw_hist(x) +
    geom_rug(sides = "b", col = cbp$blue) +
    ggtitle(paste0("Mann–Whitney U test, n = ", n))
}

figure_mw3 <- function() draw_mw(3)
figure_mw5 <- function() draw_mw(5)
figure_mw7 <- function() draw_mw(7)
figure_mw15 <- function() draw_mw(15)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
