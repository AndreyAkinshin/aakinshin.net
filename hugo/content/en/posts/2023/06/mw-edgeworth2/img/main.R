# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
exact <- function(n, m, u) pwilcox(u - 1, n, m, lower.tail = FALSE)
normal <- function(n, m, u) {
  mu <- n * m / 2
  su <- sqrt(n * m * (n + m + 1) / 12)
  z <- (u - mu - 0.5) / su
  1 - pnorm(z)
}
ew3 <- function(n, m, u) {
  mu <- n * m / 2
  su <- sqrt(n * m * (n + m + 1) / 12)
  z <- (u - mu - 0.5) / su
  phi <- dnorm(z)
  Phi <- pnorm(z)
  c20 <- function(p) -6 * (1 - p^5 - (1 - p)^5) / (25 * (p * (1 - p))^2)
  H3 <- function(x) x^3 - 3 * x
  edgeworth = Phi - phi * c20(m / (n + m)) * H3(z) / (n + m) / 24
  return(min(max(1 - edgeworth, 0), 1))
}
ew7 <- function(n, m, u) {
  mu <- n * m / 2
  su <- sqrt(n * m * (n + m + 1) / 12)
  z <- (u - mu - 0.5) / su
  phi <- dnorm(z)
  Phi <- pnorm(z)
  c20 <- function(p) -6 * (1 - p^5 - (1 - p)^5) / (25 * (p * (1 - p))^2)
  H2 <- function(x) x^2 - 1
  H3 <- function(x) x^3 - 3 * x
  H5 <- function(x) x^5 - 10 * x^3 + 15 * x
  H7 <- function(x) x^7 - 21 * x^5 + 105 * x^3 - 105 * x
  
  mu2 <- n * m * (n + m + 1) / 12
  mu4 <- n * m * (n + m + 1) * (5*m*n*(m+n) - 2 *(m^2+n^2) + 3*m*n - 2*(n+m))/240
  mu6 <- n * m * (n + m + 1) * (35*m^2*n^2*(m^2+n^2) + 70*m^3*n^3 - 42*m*n*(m^3+n^3) - 14*m^2*n^2*(n+m) + 16*(n^4+m^4) - 52*n*m*(n^2+m^2) - 43*n^2*m^2 + 32*(m^3+n^3) + 14*m*n*(n+m) + 8*(n^2+m^2) + 16*n*m - 8*(n + m))/4032
  
  e3 <- (mu4 / mu2^2 - 3) / factorial(4)
  e5 <- (mu6 / mu2^3 - 15 * mu4 / mu2^2 + 30) / factorial(6)
  e7 <- 35 * (mu4 / mu2^2 - 3)^2 / factorial(8)
  
  f3 <- -phi * H3(z)
  f5 <- -phi * H5(z)
  f7 <- -phi * H7(z)
  
  edgeworth <- Phi + e3 * f3 + e5 * f5 + e7 * f7
  return(min(max(1 - edgeworth, 0), 1))
}

draw_precision <- function(n, m, u_min = 0) {
  us <- u_min:(n * m)
  p_exact <- sapply(us, function(u) exact(n, m, u))
  p_normal <- sapply(us, function(u) normal(n, m, u))
  p_ew3 <- sapply(us, function(u) ew3(n, m, u))
  p_ew7 <- sapply(us, function(u) ew7(n, m, u))
  get_error <- function(p) p - p_exact
  df <- rbind(
    data.frame(u = us, type = "Normal", error = get_error(p_normal)),
    data.frame(u = us, type = "Edgeworth3", error = get_error(p_ew3)),
    data.frame(u = us, type = "Edgeworth7", error = get_error(p_ew7))
  )
  df$type <- factor(df$type, levels = c("Normal", "Edgeworth3", "Edgeworth7"))
  ggplot(df, aes(u, error, col = type)) +
    geom_hline(yintercept = 0, col = cbp$grey) +
    geom_line(size = 1.5) +
    ggtitle(paste0("n = ", n, ", m = ", m)) +
    scale_y_continuous(breaks = pretty(df$error, 15)) +
    scale_color_manual(values = c(cbp$red, cbp$blue, cbp$green)) +
    labs(x = "U", y = "Error (p-value)", col = "Approximation")
}

draw_pvalue <- function(n, m, u_min = 0, u_max = n * m) {
  us <- u_min:u_max
  p_exact <- sapply(us, function(u) exact(n, m, u))
  p_normal <- sapply(us, function(u) normal(n, m, u))
  p_ew3 <- sapply(us, function(u) ew3(n, m, u))
  p_ew7 <- sapply(us, function(u) ew7(n, m, u))
  
  df <- rbind(
    data.frame(u = us, type = "Exact", p = p_exact),
    data.frame(u = us, type = "Normal", p = p_normal),
    data.frame(u = us, type = "Edgeworth3", p = p_ew3),
    data.frame(u = us, type = "Edgeworth7", p = p_ew7)
  )
  df$type <- factor(df$type, levels = c("Exact", "Normal", "Edgeworth3", "Edgeworth7"))
  ggplot(df, aes(u, p, col = type)) +
    geom_point() +
    geom_line() +
    scale_color_manual(values = c(cbp$pink, cbp$red, cbp$blue, cbp$green)) +
    scale_y_continuous(trans = 'log2') +
    ggtitle(paste0("n = ", n, ", m = ", m)) +
    labs(x = "U", y = "p-value", col = "Approximation")
}
# Figures ----------------------------------------------------------------------
figure_precision_a <- function() draw_precision(10, 10)
figure_precision_b <- function() draw_precision(30, 30)
figure_precision_c <- function() draw_precision(50, 5)
figure_pvalue_a <- function() draw_pvalue(50, 5, 220)
figure_pvalue_b <- function() draw_pvalue(40, 40, 1200)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
