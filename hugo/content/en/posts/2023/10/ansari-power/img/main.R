source("utils.R")

# Data -------------------------------------------------------------------------
build_df <- function(n, alpha) {
  filename <- paste0("data-", n, "-", alpha * 100, ".csv")
  if (file.exists(filename))
    return(read.csv(filename))
  
  set.seed(1729)
  m <- 10000
  
  rD <- function(n) rnorm(n)
  
  t_rate <- function(ratio) {
    sum(replicate(m, t.test(rD(n) * ratio, rD(n))$p.value < alpha)) / m
  }
  mw_rate <- function(ratio) {
    sum(replicate(m, wilcox.test(rD(n) * ratio, rD(n), exact = TRUE)$p.value < alpha)) / m
  }
  ab_rate <- function(ratio) {
    sum(replicate(m, ansari.test(rD(n) * ratio, rD(n), exact = TRUE)$p.value < alpha)) / m
  }

  ratios <- seq(1, 10, by = 0.2)
  df <- rbind(
    data.frame(ratio = ratios, rate = sapply(ratios, t_rate), type = "t"),
    data.frame(ratio = ratios, rate = sapply(ratios, mw_rate), type = "mw"),
    data.frame(ratio = ratios, rate = sapply(ratios, ab_rate), type = "ab")
  )
  write.csv(df, filename, quote = FALSE, row.names = FALSE)
  df
}

draw_pc <- function(n, alpha = 0.05) {
  df <- build_df(n, alpha)
  df$type <- factor(df$type, levels = c("t", "mw", "ab"))
  ggplot(df, aes(ratio, rate, col = type)) +
    geom_line() +
    scale_x_continuous(breaks = seq(1, 10, by = 0.5)) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.05)) +
    scale_color_manual(
      values = cbp$values,
      labels = c("Welch's t", "Mann–Whitney U", "Ansari-Bradley")
    ) +
    labs(
      title = paste0("Power curve (normal distribution, n=", n, ", alpha=", alpha, ", two-sided)"),
      x = "Ratio",
      y = "Statistical power",
      col = ""
    ) + 
    theme(legend.position = "bottom")
}

figure_pc5 <- function() draw_pc(5)
figure_pc10 <- function() draw_pc(10)
figure_pc20 <- function() draw_pc(20)

regenerate_figures()
