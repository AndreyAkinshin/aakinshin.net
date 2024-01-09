# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------
draw_timeline <- function(index, stage, palette, ma, mb) {
  n <- length(stage)
  build_df <- function(letter, m) data.frame(
    type = paste0("(", index, letter, ")"),
    x = 1:n,
    y = rnorm(n, m[stage]),
    stage = stage
  )
  
  set.seed(1729)
  df <- rbind(build_df("a", ma),
              build_df("b", mb))
  df$stage <- factor(df$stage, levels = 1:3)
  cpts <- (1:n)[tail(stage, -1) - head(stage, -1) == 1]
  
  ggplot(df, aes(x, y, col = stage)) +
    geom_point() +
    geom_vline(xintercept = cpts, col = cbp$grey, linetype = "dotted") +
    facet_wrap(vars(type), nrow = 1) +
    scale_x_continuous(breaks = pretty(1:n, 9)) +
    scale_color_manual(values = palette) +
    labs(x = "Iteration",
         y = "Measurement") +
    theme(legend.position = "none",
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank())
}

# Figures ----------------------------------------------------------------------
figure_timeline1 <- function() {
  draw_timeline(1,
    c(rep(1, 200), rep(2, 50), rep(3, 150)),
    c(cbp$green, cbp$red, cbp$blue),
    c(0, 5, 0),
    c(0, 5, 3))
}

figure_timeline2 <- function() {
  draw_timeline(2,
    c(rep(1, 200), rep(2, 150)),
    c(cbp$green, cbp$blue),
    c(0, 0),
    c(0, 3))
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
