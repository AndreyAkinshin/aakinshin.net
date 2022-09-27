# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

hdm <- function(x) as.numeric(hdquantile(x, 0.5))

sc <- function(Tn, n = 10) {
  X <- qnorm(1:n / (n + 1))
  limit <- 100
  x <- seq(-limit, limit, length.out = 1001)
  y <- sapply(x, function(x0) (Tn(c(X, x0)) - Tn(X)) * (n + 1))
  data.frame(x, y, n = n)
}

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------

helper_figure_sc <- function(ns) {
  df <- do.call("rbind", lapply(ns, function(n) sc(hdm, n)))
  df$n <- factor(df$n, levels = ns)
  ggplot(df, aes(x, y, col = n, group = n)) +
    geom_line()
}

figure_sc1 <- function() {
  helper_figure_sc(2:5)
}

figure_sc2 <- function() {
  helper_figure_sc(6:10)
}

figure_sc3 <- function() {
  helper_figure_sc(c(10, 15, 20, 25, 30))
}


# Plotting ---------------------------------------------------------------------
regenerate_figures()
