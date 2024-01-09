# Scripts ----------------------------------------------------------------------
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_eff <- function() {
  df1 <- read.csv("data-efficiency.csv")
  df2 <- read.csv("data-scale-efficiency.csv")
  df <- rbind(
    data.frame(n = df1$n, mad = df1$eff.madn, sn = df1$eff.sn, qn = df1$eff.qn) %>% gather("estimator", "eff", -n),
    data.frame(n = df2$n, sqad = df2$eff.sqad, oqad = df2$eff.oqad) %>% gather("estimator", "eff", -n)
  )
  df <- df[df$n < 50, ]
  df$parity <- df$n %% 2
  df$estimator <- factor(df$estimator, levels = c("mad", "sn", "qn", "sqad", "oqad"))
  labels <- c("MAD", "RC Sn", "RC Qn", "SQAD", "OQAD")
  ggplot(df, aes(n, eff, col = estimator, shape = estimator)) +
    geom_point() +
    scale_color_manual(values = cbp$values, labels = labels) +
    scale_shape(labels = labels) +
    scale_x_continuous(breaks = seq(0, 50, by = 5)) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    labs(
      x = "N (Sample size)",
      y = "Efficiency",
      col = "Estimator",
      shape = "Estimator",
      title = "Gaussian efficiency of scale estimators"
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
