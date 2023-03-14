# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
bm <- function (x, y, alternative = c("two.sided", "greater", "less"), 
                alpha = 0.05) 
{
  alternative <- match.arg(alternative)
  x <- na.omit(x)
  y <- na.omit(y)
  n1 = length(x)
  n2 = length(y)
  r1 = rank(x)
  r2 = rank(y)
  r = rank(c(x, y))
  m1 = mean(r[1:n1])
  m2 = mean(r[n1 + 1:n2])
  pst = (m2 - (n2 + 1)/2)/n1
  v1 = sum((r[1:n1] - r1 - m1 + (n1 + 1)/2)^2)/(n1 - 1)
  v2 = sum((r[n1 + 1:n2] - r2 - m2 + (n2 + 1)/2)^2)/(n2 - 1)
  statistic = n1 * n2 * (m2 - m1)/(n1 + n2)/sqrt(n1 * v1 + 
                                                   n2 * v2)
  dfbm = ((n1 * v1 + n2 * v2)^2)/(((n1 * v1)^2)/(n1 - 1) + 
                                    ((n2 * v2)^2)/(n2 - 1))
  if ((alternative == "greater") | (alternative == "g")) {
    p.value = pt(statistic, dfbm)
    if (is.na(p.value)) {
      if (min(x) > max(y))
        p.value = 0
      if (min(y) > max(x))
        p.value = 1
    }
  }
  else if ((alternative == "less") | (alternative == "l")) {
    p.value = 1-pt(statistic, dfbm)
    if (is.na(p.value)) {
      if (min(x) > max(y))
        p.value = 1
      if (min(y) > max(x))
        p.value = 0
    }
  }
  else {
    alternative = "two.sided"
    p.value = 2 * min(pt(abs(statistic), dfbm), (1 - pt(abs(statistic), 
                                                        dfbm)))
    if (is.na(p.value))
      p.value = 0
  }
  p.value
}

# Data -------------------------------------------------------------------------

# Tables -----------------------------------------------------------------------

# Figures ----------------------------------------------------------------------
draw_hist <- function(x) {
  ggplot(data.frame(x), aes(x)) +
    geom_histogram(binwidth = 0.01, boundary = 0, fill = cbp$red, alpha = 0.5) +
    geom_histogram(binwidth = 0.01, boundary = 0, fill = "transparent", col = cbp$red) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
    labs(x = "p-value", y = "Count")
}

draw_bm <- function(n) {
  set.seed(1729)
  x <- replicate(100000, bm(rnorm(n), rnorm(n)))
  draw_hist(x) +
    geom_rug(sides = "b", col = cbp$blue) +
    ggtitle(paste0("Brunner–Munzel test, n = ", n))
}

figure_bm3 <- function() draw_bm(3)
figure_bm5 <- function() draw_bm(5)
figure_bm7 <- function() draw_bm(7)
figure_bm15 <- function() draw_bm(15)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
