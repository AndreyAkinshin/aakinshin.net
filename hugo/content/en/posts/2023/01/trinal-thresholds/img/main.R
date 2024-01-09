# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------

draw <- function(m1, m2, s) {
  x <- seq(min(m1, m2) - s * 3 - 1, max(m1, m2) + s * 3 + 1, by = 0.01)
  df <- rbind(
    data.frame(x, y = dnorm(x, m1, s), type = "D1"),
    data.frame(x, y = dnorm(x, m2, s), type = "D2")
  )
  dfm <- rbind(
    data.frame(x = m1, y = dnorm(m1, m1, s), type = "D1"),
    data.frame(x = m2, y = dnorm(m2, m2, s), type = "D2")
  )
  title <- paste0(
    "N(", m1, ", ", s, "^2) vs. N(", m2, ", ", s, "^2): ",
    "Shift = ", m2 - m1,
    ", Ratio = ", m2 / m1, " (+", round((m2 / m1 - 1) * 100, 2), "%)",
    ", EffectSize = ", (m2 - m1) / s)
  p <- ggplot(df, aes(x, y, col = type)) +
    geom_line() +
    geom_segment(data = dfm, aes(x, 0, xend = x, yend = y, col = type), linetype = "dashed") +
    scale_color_manual(values = cbp$values) +
    scale_x_continuous(breaks = pretty(x, 10)) +
    labs(
      x = "Value",
      y = "Density",
      title = title,
    ) +
    theme(legend.position = "none")
  if (s < 1e-9)
    p <- p +
      scale_y_continuous(limits = c(0, 10)) +
      theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
  p
}

figure_ex1 <- function() draw(10, 11, 1)
figure_ex2 <- function() draw(1000, 1001, 100)
figure_ex3 <- function() draw(1000, 1001, 0.1)
figure_ex4 <- function() draw(0.01, 1, 10)
figure_ex5 <- function() draw(10, 12, 0)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
