# TODO: Use Loeffler to get the true U-statistic density
# TODO: Smothify CDF(U)
# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Functions --------------------------------------------------------------------
ess <- function(w, beta) {
  w <- w / sum(w)
  sum(w^beta)^(1 / (1 - beta))
}
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
wexp <- function(n, hl) 2^(-((0:(n - 1))/hl))

# Figures ----------------------------------------------------------------------
draw <- function(title, n, m, w = rep(1, n), v = rep(1, m), REP = 100000) {
  ns <- round(kish(w))
  ms <- round(kish(v))
  u1 <- replicate(REP, mw2(runif(ns), runif(ms)))
  u2 <- replicate(REP, mw2(runif(ns), runif(ms)))
  u2 <- replicate(REP, wmw(runif(n), runif(m), w, v))
  df <- rbind(
    data.frame(type = "Classic", u = u1),
    data.frame(type = "Weighted", u = u2)
  )
  p1 <- ggplot(df, aes(u, col = type, fill = type)) +
    # geom_density(bw = 2 / (ns * ms)) +
    geom_histogram(aes(y = ..density..), position = "identity", bins = ns * ms * 4, alpha = 0.5) +
    geom_rug(sides = "b") +
    geom_rug(data = df[df$type == "Classic",], sides = "b", size = 2) +
    geom_hline(yintercept = 0, col = cbp$grey) +
    scale_x_continuous(breaks = pretty(0:(ns * ms), 7, bounds = TRUE)) +
    scale_color_manual(values = cbp$values) +
    labs(
      x = "U",
      y = "Density",
      col = "Mann-Whitney",
      fill = "Mann-Whitney",
      title = "U-statistic density"
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "bottom"
    )
  
  step <- 0.005
  probs <- seq(step, 1 - step, by = step)
  df2 <- data.frame(
    probs = probs,
    diff = quantile(u2, probs) - quantile(u1, probs)
  )
  p2 <- ggplot(df2, aes(probs, diff)) +
    geom_line() +
    geom_hline(yintercept = 0, col = cbp$green) +
    labs(
      x = "Quantile order",
      y = "Quantile shift",
      title = "Doksum's quantile shift"
    )
  grid.arrange(p1, p2, ncol = 2,
               top = paste0(title, " [n = ", n, ", m = ", m, ", n* = ", ns, ", m*=", ms, "]"))
}

#draw("Exp(HL=1.15) vs. Exp(HL=1.15)", 10, 10, wexp(10, 1.15), wexp(10, 1.15))

# Check
figure_unif10 <- function() draw("Uniform vs. Uniform", 10, 10)
figure_unif30 <- function() draw("Uniform vs. Uniform", 30, 30)

# Target
figure_exp5 <- function() draw("Exp(HL=11.455) vs. Uniform", 50, 5, wexp(50, 11.455))
figure_exp4 <- function() draw("Exp(HL=11.455) vs. Uniform", 50, 4, wexp(50, 11.455))
figure_exp3 <- function() draw("Exp(HL=11.455) vs. Uniform", 50, 3, wexp(50, 11.455))
figure_exp2 <- function() draw("Exp(HL=11.455) vs. Uniform", 50, 2, wexp(50, 11.455))

# Corner
figure_exp_exp <- function() draw("Exp(HL=3.189) vs. Exp(HL=5.154)", 20, 20, wexp(20, 3.189), wexp(20, 5.154))

# Plotting ---------------------------------------------------------------------
regenerate_figures()
