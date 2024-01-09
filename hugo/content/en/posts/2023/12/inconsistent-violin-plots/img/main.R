# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_violin <- function() {
  set.seed(7353)
  x <- rnorm(30)
  
  ggplot(data.frame(x), aes(x, 1)) + 
    geom_violin(bw = 0.9, trim = FALSE, draw_quantiles = 0.5,
                col = cbp$blue, fill = "transparent", linewidth = 1.1) +
    geom_boxplot(width = 0.3, col = cbp$red, fill = "transparent", linewidth = 1.1) +
    geom_rug(sides = "b") +
    scale_x_continuous(limits = c(-3.5, 3.5), breaks = -3:3) +
    theme(
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank()
    ) +
    labs(x = "x", y = "Density")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
