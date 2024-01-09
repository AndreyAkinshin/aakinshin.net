# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
cucconi_statistic <- function(x, y) {
  n <- length(x)
  m <- length(y)
  N <- n + m
  S <- rank(c(x, y))[(n + 1):N]
  denominator <- sqrt(n * m * (N + 1) * (2 * N + 1) * (8 * N + 11) / 5)
  S_base <- m * (N + 1) * (2 * N + 1)
  
  U <- (6 * sum(S^2) - S_base) / denominator
  V <- (6 * sum((N + 1 - S)^2) - S_base) / denominator
  rho <- (2 * (N^2 - 4))/((2 * N + 1) * (8 * N + 11)) - 1
  
  C <- (U^2 + V^2 - 2 * rho * U * V)/(2 * (1 - rho^2))
  return(C)
}

cucconi_distribution <- function(n, m, reps = 10000) {
  N <- n + m
  random_statistic <- function() {
    data <- sample(1:N)
    x <- data[1:n]
    y <- data[(n + 1):N]
    return(cucconi_statistic(x = x, y = y))
  }
  return(replicate(reps, random_statistic()))
}

cucconi_cache <- new.env()
cucconi_distribution2 <- function(n, m) {
  key <- paste0(n, "-", m)
  if (exists(key, envir = cucconi_cache)) {
    return(get(key, envir = cucconi_cache))
  }
  
  result <- cucconi_distribution(n, m)
  assign(key, result, envir = cucconi_cache)
  return(result)
}

cucconi_test <- function(x, y) {
  C <- cucconi_statistic(x, y)
  d <- cucconi_distribution2(length(x), length(y))
  p_value <- length(d[d >= C]) / length(d)
  return(list(C = C, p_value = p_value))
}

# Data -------------------------------------------------------------------------
build_df <- function(n, alpha) {
  filename <- paste0("data-", n, "-", alpha * 100, ".csv")
  if (file.exists(filename))
    return(read.csv(filename))
  
  set.seed(1729)
  m <- 10000
  
  rD <- function(n) rnorm(n)
  
  t_rate <- function(es) {
    sum(replicate(m, t.test(rD(n) + es, rD(n))$p.value < alpha)) / m
  }
  mw_rate <- function(es) {
    sum(replicate(m, wilcox.test(rD(n) + es, rD(n))$p.value < alpha)) / m
  }
  cuc_rate <- function(es) {
    sum(replicate(m, cucconi_test(rD(n) + es, rD(n))$p_value < alpha)) / m
  }
  
  ess <- seq(-2, 2, by = 0.05)
  df <- rbind(
    data.frame(es = ess, rate = sapply(ess, t_rate), type = "t"),
    data.frame(es = ess, rate = sapply(ess, mw_rate), type = "mw"),
    data.frame(es = ess, rate = sapply(ess, cuc_rate), type = "cuc")
  )
  write.csv(df, filename, quote = FALSE, row.names = FALSE)
  df
}

draw_pc <- function(n, alpha = 0.05) {
  df <- build_df(n, alpha)
  df$type <- factor(df$type, levels = c("t", "mw", "cuc"))
  ggplot(df, aes(es, rate, col = type)) +
    geom_line() +
    scale_x_continuous(breaks = seq(-2, 2, by = 0.5)) +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.1)) +
    scale_color_manual(
      values = cbp$values,
      labels = c("Student's t", "Mann–Whitney U", "Cucconi C")
    ) +
    labs(
      title = paste0("Power curve (normal distribution, n=", n, ", alpha=", alpha, ", two-sided)"),
      x = "Effect size",
      y = "Statistical power",
      col = ""
    ) + 
    theme(legend.position = "bottom")
}

# Figures ----------------------------------------------------------------------
figure_pc5 <- function() draw_pc(5)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
