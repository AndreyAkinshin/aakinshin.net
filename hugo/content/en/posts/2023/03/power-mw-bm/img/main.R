# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

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
estimate <- function(alpha, n) {
  filename <- paste0("data-", round(alpha * 1000), "-", n, ".csv")
  if (file.exists(filename))
    return(read.csv(filename))
  m <- 50000
  df <- do.call("rbind", lapply(seq(0.1, 2, by = 0.05), function(es) {
    data.frame(
      es = es,
      bm = sum(replicate(m, bm(rnorm(n), rnorm(n, es), "l")) < alpha) / m,
      mw = sum(replicate(m, wilcox.test(rnorm(n), rnorm(n, es), "l")$p.value) < alpha) / m
    )
  }))
  write.csv(df, filename, row.names = FALSE, quote = FALSE)
  df
}

# Figures ----------------------------------------------------------------------
draw <- function(alpha, n) {
  df <- estimate(alpha, n)
  df <- df %>% gather("estimator", "value", -es)
  df$estimator <- factor(df$estimator, levels = c("mw", "bm"))
  ggplot(df, aes(es, value, col = estimator)) +
    geom_line() +
    geom_point() +
    xlim(0, NA) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1), limits = c(0, 1)) +
    scale_color_manual(labels = c("Mann-Whitney", "Brunner-Munzel"), values = cbp$values) +
    labs(
      title = paste0("Statistical power (alpha = ", alpha, ", n = ", n, ")"),
      x = "Delta (effect size)",
      y = "Statistical power",
      col = "Test"
    ) +
    theme(legend.position = "bottom")
}

figure_sp_050_05 <- function() draw(0.050, 05)
figure_sp_050_10 <- function() draw(0.050, 10)
figure_sp_050_30 <- function() draw(0.050, 30)

figure_sp_010_05 <- function() draw(0.010, 05)
figure_sp_010_10 <- function() draw(0.010, 10)
figure_sp_010_30 <- function() draw(0.010, 30)

figure_sp_005_05 <- function() draw(0.005, 05)
figure_sp_005_10 <- function() draw(0.005, 10)
figure_sp_005_30 <- function() draw(0.005, 30)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
