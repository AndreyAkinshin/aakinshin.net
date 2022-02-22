library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(dplyr)
library(latex2exp)
library(knitr)
library(stringr)
library(jsonlite)
library(gridExtra)
library(evd)
library(ggplot2)
library(e1071)
library(rmutil)
library(latex2exp)

rm(list = ls())

# Helpers
cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 200) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 900 / dpi
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

# Main

x0 <- c(1, 1, 1, 1, 1, 1, 1, 2, 3, 5, 8)
mad <- function(x) median(abs(x - median(x)))
qad <- function(x, p, q) quantile(abs(x - quantile(x, p)), q)
qadm <- function(q) qad(x0, 0.5, q)
probs <- seq(0, 1, by = 0.01)
qad.values <- sapply(probs, function(p) qadm(p))
q0 <- last(probs[qad.values < 1e-9])
qm <- (q0 + 1) / 2
df <- data.frame(x = probs, y = qad.values)
p <- ggplot(df, aes(x, y)) +
  geom_line(col = cbRed) +
  geom_point(
    data = data.frame(x = c(0.5, q0, qm, 1), y = c(0, qadm(q0), qadm(qm), qadm(1))),
    col = cbNavy,
    size = 3
  ) +
  geom_line(
    data = data.frame(x = c(qm, qm), y = c(0, qadm(qm))),
    col = cbBlue,
    linetype = "dashed"
  ) +
  geom_line(
    data = data.frame(x = c(1, 1), y = c(0, qadm(1))),
    col = cbBlue,
    linetype = "dashed"
  ) +
  labs(
    x = "q",
    y =TeX("QAD(x,½,q)"),
    title = paste0("QAD for x = {", paste(x0, collapse = ","), "}")
  ) +
  annotate(
    x = qm-0.05, y = qadm(qm) + 1, label = TeX("QAD(x,½,q_m)"),
    geom = "text", col = cbGreen, size = 8, vjust = -0.5, hjust = 0.5) +
  annotate(
    x = 0.5-0.05, y = 1, label = TeX("QAD(x,½,½)=MAD(x)"),
    geom = "text", col = cbGreen, size = 8, vjust = -0.5, hjust = 0.5) +
  annotate("segment", x = 0.5-0.05, xend = 0.5, y = 1, yend = 0, arrow = arrow(), col = cbGreen) +
  annotate("segment", x = qm-0.05, xend = qm, y = qadm(qm)+1, yend = qadm(qm), arrow = arrow(), col = cbGreen) +
  theme(text = element_text(size=20)) +
  scale_x_continuous(
    breaks = c(0, 0.25, 0.5, q0, 0.75, qm, 1.0),
    labels = c(0, 0.25, 0.5, TeX("q_0"), 0.75, TeX("q_m"), 1)
  )
p + theme_bw()
ggsave_nice("plot1", p)