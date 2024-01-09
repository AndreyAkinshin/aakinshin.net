# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
hlr <- function(x, y) median(outer(x, y, "/"))

# Figures ----------------------------------------------------------------------
figure_sampling <- function() {
  n <- 10
  set.seed(1729)
  df <- data.frame(
    hlr = replicate(10000, hlr(runif(n, 20, 40), runif(n, 10, 20)))
  )
  ggplot(df, aes(hlr)) +
    geom_density(bw = "SJ") +
    labs(x = "HLR", y = "Density")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
