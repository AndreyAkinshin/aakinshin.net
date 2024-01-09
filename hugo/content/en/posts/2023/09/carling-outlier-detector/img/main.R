# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
carling_k <- function(n) (17.63 * n - 23.64) / (7.74 * n - 3.71)

check <- function(n, detector) {
  x <- rnorm(n)
  f <- detector(x)
  (sum(x < f[1]) + sum(x > f[2])) / n
}

fences <- function(x, k) {
  q <- quantile(x, c(0.25, 0.75))
  iqr <- q[2] - q[1]
  c(q[1] - k * iqr, q[2] + k * iqr)
}
tukey15 <- function(x) fences(x, 1.5)
tukey30 <- function(x) fences(x, 3.0)
carling <- function(x) fences(x, carling_k(length(x)))

# Figures ----------------------------------------------------------------------
figure_carling_k <- function() {
  n <- 2:50
  k <- carling_k(n)
  ggplot(data.frame(n, k), aes(n, k)) +
    geom_point() +
    geom_line() +
    ylab("Sample size (n)") +
    ggtitle("Carling's k") +
    scale_x_continuous(limits = c(0, NA), breaks = seq(0, 50, by = 5)) +
    scale_y_continuous(limits = c(0.9, NA), breaks = seq(0, 3, by = 0.1))
}

figure_rate <- function() {
  build_df <- function(ns, m = 10000) {
    do.call("rbind", lapply(ns, function(n) {
      data.frame(
        n = n,
        tukey15 = sum(replicate(m, check(n, tukey15)) > 0) / m,
        tukey30 = sum(replicate(m, check(n, tukey30)) > 0) / m,
        carling = sum(replicate(m, check(n, carling)) > 0) / m
      )
    }))
  }
  
  filename <- "data.csv"
  if (file.exists(filename)) {
    df <- read.csv(filename)
  } else {
    set.seed(1729)
    ns <- c(seq(2, 20, by = 1), seq(25, 100, by = 5), seq(110, 300, by = 10))
    df <- build_df(ns)
    write.csv(df, filename, quote = FALSE, row.names = FALSE)
  }
  df <- df %>% gather("detector", "rate", -n)
  df$detector <- factor(df$detector, levels = c("tukey15", "tukey30", "carling"))
  df <- df[df$n >= 10,]
  ggplot(df, aes(n, rate, col = detector)) +
    geom_point() +
    geom_line() +
    ylim(0, 1) +
    scale_color_manual(values = c(cbp$red, cbp$blue, cbp$green)) +
    labs(
      x = "Sample size (n)",
      y = "Probability of getting outliers",
      title = "Outlier detection under normality"
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
