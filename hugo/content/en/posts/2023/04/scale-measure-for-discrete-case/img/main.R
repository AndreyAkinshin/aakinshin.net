# Scripts ----------------------------------------------------------------------
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_s <- function() {
  s <- seq(0, 5, by = 0.01)
  types <- c("s", "s+1", "√(s^2+1^2)")
  df <- rbind(
    data.frame(s = s, ss = 1 / s, type = types[1]),
    data.frame(s = s, ss = 1 / (s + 1), type = types[2]),
    data.frame(s = s, ss = 1 / sqrt(s^2 + 1), type = types[3])
  )
  df$type <- factor(df$type, levels = types)
  ggplot(df, aes(s, ss, col = type)) +
    geom_line() +
    labs(
      x = "s",
      y = "1/s'",
      col = "s'"
    ) +
    ylim(0, 5) +
    scale_color_manual(values = cbp$values)
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
