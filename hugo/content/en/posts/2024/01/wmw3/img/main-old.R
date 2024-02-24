# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Functions --------------------------------------------------------------------
kish <- function(w) sum(w)^2 / sum(w^2)
mw <- function(x, y) wilcox.test(x, y, "greater", exact = TRUE)$statistic
wmw <- function(x, y, w = rep(1, length(x)), v = rep(1, length(y))) {
  w <- w / sum(w)
  v <- v / sum(v)
  index <- expand.grid(i = 1:length(x), j = 1:length(y))
  S <- function(a, b) (sign(a - b) + 1) / 2
  U <- sum(S(x[index$i], y[index$j]) * w[index$i] * v[index$j])
  U * round(kish(w)) * round(kish(v))
}
mw2 <- function(x, y) wmw(x, y)
wexp <- function(hl, n) 2^(-((0:(n - 1))/hl))

# Figures ----------------------------------------------------------------------
draw <- function(title, n, m, w = rep(1, n), v = rep(1, m), REP = 50000) {
  ns <- round(kish(w))
  ms <- round(kish(v))
  u1 <- replicate(REP, mw2(runif(ns), runif(ms)))
  u2 <- replicate(REP, mw2(runif(ns), runif(ms)))
  u2 <- replicate(REP, wmw(runif(n), runif(m), w, v))
  df <- rbind(
    data.frame(type = "Classic", u = u1),
    data.frame(type = "Weighted", u = u2)
  )
  p1 <- ggplot(df, aes(u, col = type)) +
    geom_density(bw = max(ns * ms / 30, 1)) +
    scale_color_manual(values = cbp$values) +
    labs(
      x = "U",
      y = "Density",
      col = "Mann-Whitney",
      title = "U-statistic density"
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "bottom"
    )
  
  step <- 0.001
  probs <- seq(step, 1 - step, by = step)
  df2 <- data.frame(
    probs = probs,
    diff = hdquantile(u2, probs) - hdquantile(u1, probs)
  )
  p2 <- ggplot(df2, aes(probs, diff)) +
    geom_point() +
    geom_hline(yintercept = 0, col = cbp$green) +
    labs(
      x = "Quantile order",
      y = "Quantile shift",
      title = "Doksum's quantile shift"
    )
  grid.arrange(p1, p2, ncol = 2,
               top = paste0(title, " [n = ", n, ", m = ", m, "]"))
}

# Check
draw("Uniform vs. Uniform", 10, 10)
draw("Uniform vs. Uniform", 30, 30)

# Target
draw("Exp(HL=11.455) vs. Uniform", 50, 5, wexp(11.455, 50))
draw("Exp(HL=11.455) vs. Uniform", 50, 4, wexp(11.455, 50))
draw("Exp(HL=11.455) vs. Uniform", 50, 3, wexp(11.455, 50))
draw("Exp(HL=11.455) vs. Uniform", 50, 2, wexp(11.455, 50))

# Corner
draw("Exp(HL=3.189) vs. Exp(HL=5.154)", 20, 20, wexp(3.189, 20), wexp(5.154, 20))

# Plotting ---------------------------------------------------------------------
#regenerate_figures()
