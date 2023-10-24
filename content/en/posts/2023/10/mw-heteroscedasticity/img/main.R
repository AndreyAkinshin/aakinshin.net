# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
build_df <- function(n, alpha) {
  filename <- paste0("data-", n, "-", alpha * 100, ".csv")
  if (file.exists(filename))
   return(read.csv(filename))
  
  set.seed(1729)
  m <- 100000
  
  rD <- function(n) rnorm(n)
  
  mw_rate <- function(ratio) {
    sum(replicate(m, wilcox.test(rD(n) * ratio, rD(n))$p.value < alpha)) / m
  }
  
  ratios <- seq(1, 20, by = 1)
  df <- data.frame(ratio = ratios, rate = sapply(ratios, mw_rate), type = "mw")
  write.csv(df, filename, quote = FALSE, row.names = FALSE)
  df
}

draw_pc <- function(n, alpha = 0.05) {
  df <- build_df(n, alpha)
  df$type <- factor(df$type, levels = c("mw"))
  ggplot(df, aes(ratio, rate, col = type)) +
    geom_line() +
    scale_x_continuous(breaks = 1:20) +
    scale_y_continuous(limits = c(0, NA), breaks = seq(0, 1, 0.01)) +
    scale_color_manual(
      values = cbp$values,
      labels = c("Mann–Whitney U")
    ) +
    geom_hline(yintercept = alpha) +
    labs(
      title = paste0("Power curve (normal distribution, n=", n, ", alpha=", alpha, ", two-sided)"),
      x = "Ratio",
      y = "Statistical power",
      col = ""
    ) + 
    theme(legend.position = "bottom")
}

# Figures ----------------------------------------------------------------------
figure_pc01 <- function() draw_pc(30, 0.01)
figure_pc05 <- function() draw_pc(30, 0.05)
figure_pc10 <- function() draw_pc(30, 0.10)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
