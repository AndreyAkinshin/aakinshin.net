# Scripts ----------------------------------------------------------------------
source("utils.R")

# Data -------------------------------------------------------------------------
build_df <- function(n, alpha) {
  filename <- paste0("data-", n, "-", alpha * 100, ".csv")
  if (file.exists(filename))
    return(read.csv(filename))
  
  set.seed(1729)
  m <- 20000

  t_rate <- function(es) {
    sum(replicate(m, t.test(rnorm(n, es), rnorm(n), "g")$p.value < alpha)) / m
  }
  mw_rate <- function(es) {
    sum(replicate(m, wilcox.test(rnorm(n, es), rnorm(n), "g")$p.value < alpha)) / m
  }

  ess <- seq(-1, 2, by = 0.05)
  df <- rbind(
    data.frame(es = ess, rate = sapply(ess, t_rate), type = "t"),
    data.frame(es = ess, rate = sapply(ess, mw_rate), type = "mw")
  )
  write.csv(df, filename, quote = FALSE, row.names = FALSE)
  df
}

build_diff <- function(n = 10, alpha = 0.05) {
  df <- build_df(n, alpha)
  df2 <- df %>% spread("type", "rate")
  df2$diff <- abs(df2$t - df2$mw)
  df2
}

# Figures ----------------------------------------------------------------------
draw_pc <- function(n, alpha = 0.05) {
  df <- build_df(n, alpha)
  df$type <- factor(df$type, levels = c("t", "mw"))
  ggplot(df, aes(es, rate, col = type)) +
    geom_line() +
    scale_x_continuous(breaks = seq(-1, 2, by = 0.5)) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.1)) +
    scale_color_manual(
      values = cbp$values,
      labels = c("Student's t", "Mann–Whitney U")
    ) +
    labs(
      title = paste0("Power curve (normal distribution, n=", n, ", alpha=", alpha, ")"),
      x = "Effect size",
      y = "Statistical power",
    col = ""
    ) + 
    theme(legend.position = "bottom")
}

figure_pc10 <- function() draw_pc(10)
figure_pc20 <- function() draw_pc(20)
figure_pc30 <- function() draw_pc(30)
figure_pc100 <- function() draw_pc(100)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
