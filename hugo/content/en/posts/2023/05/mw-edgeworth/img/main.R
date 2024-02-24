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
ew <- function(n, m, u) {
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

# Figures ----------------------------------------------------------------------
draw <- function(n, m, u_min = 0) {
  us <- u_min:(n * m)
  p_exact <- sapply(us, function(u) exact(n, m, u))
  p_normal <- sapply(us, function(u) normal(n, m, u))
  p_ew <- sapply(us, function(u) ew(n, m, u))
  get_error <- function(p) p - p_exact
  df <- rbind(
    data.frame(u = us, type = "Normal", error = get_error(p_normal)),
    data.frame(u = us, type = "Edgeworth", error = get_error(p_ew))
  )
  df$type <- factor(df$type, levels = c("Normal", "Edgeworth"))
  ggplot(df, aes(u, error, col = type)) +
    geom_hline(yintercept = 0, col = cbp$grey) +
    geom_line() +
    ggtitle(paste0("n = ", n, ", m = ", m)) +
    scale_y_continuous(breaks = pretty(df$error, 15)) +
    scale_color_manual(values = c(cbp$red, cbp$green)) +
    labs(x = "U", y = "Error (p-value)", col = "Approximation")
}
figure_nm50_5 <- function() draw(50, 5)
figure_nm10 <- function() draw(10, 10)
figure_nm30 <- function() draw(30, 30)
figure_nm50 <- function() draw(50, 50)
figure_nm50a <- function() draw(50, 50, 2000)
figure_nm50b <- function() draw(50, 50, 2100)
figure_nm50c <- function() draw(50, 50, 2200)
figure_nm50d <- function() draw(50, 50, 2300)
figure_nm50e <- function() draw(50, 50, 2400)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
