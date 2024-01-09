# Scripts ----------------------------------------------------------------------
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_clt <- function() {
  build <- \(rD, n, m = 10000) data.frame(n = n, x = replicate(m, mean(rD(n))))
  build2 <- \(rD) do.call("rbind", lapply(c(10, 20, 30, 100, 500, 1000), \(n) build(rD, n)))
  
  df <- build2(\(n) rlnorm(n, 0, 2))
  
  ggplot(df, aes(x)) +
    geom_density(bw = "SJ", aes(y = ..scaled.. * 0.5)) +
    geom_rug(sides = "b") +
    facet_wrap(vars(n), scales = "free", ncol = 3) +
    labs(
      x = "Mean distribution",
      y = "Density",
      title = "Log-Normal (m = 0, s = 2)"
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
