# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------

figure_multimodality <- function() {
  set.seed(42)
  n <- 10
  sd <- 1
  modes <- 4
  delta <- 10
  x <- as.vector(sapply(1:modes, function(i) delta * (i + 1) + rnorm(n, sd = sd)))
  x.min <- min(x) - delta * 2
  x.max <- max(x) + delta * 2
  
  p <- ggplot(data.frame(x = x), aes(x)) + 
    ylab("") +
    geom_rug() +
    scale_x_continuous(limits = c(x.min, x.max), breaks = seq(0, 70, by = 10))

  p1 <- p + geom_density(bw = "nrd0") + ggtitle("Silverman")
  p2 <- p + geom_density(bw = "nrd") + ggtitle("Scott")
  p3 <- p + geom_density(bw = "bcv") + ggtitle("Biased cross-validation")
  p4 <- p + geom_density(bw = "ucv") + ggtitle("Unbiased cross-validation")
  p5 <- p + geom_density(bw = "SJ") + ggtitle("Sheather & Jones")
  p6 <- p + geom_density(bw = 1) + ggtitle("Manual (bandwidth = 1)")
  grid.arrange(p1, p2, p3, p4, p5, p6, nrow = 2)
}

figure_wobbliness <- function() {
  set.seed(1729)
  data <- data.frame(x = rexp(1000))

  ggplot(data, aes(x)) +
    geom_density(aes(colour = "Sheather & Jones"), bw = "SJ") +
    geom_density(aes(colour = "Unbiased cross-validation"), bw = "ucv") +
    geom_rug(sides = "b") +
    scale_color_manual(values = cbp$values) +
    labs(col = "Bandwidth selector:", y = "Density") +
    theme(legend.position = "bottom")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
