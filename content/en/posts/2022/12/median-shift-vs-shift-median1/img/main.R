# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
ms <- function(x, y) median(y) - median(x)
hl <- function(x, y) median((expand.grid(x = x, y = y) %>% mutate(d = y - x))$d)
rD <- function(n, med = 0, dir = 1) {
  n1 <- (n %/% 2) + 1
  n1 <- round(n * 0.6)
  n2 <- n - n1
  c(
    med + dir * rbeta(n1, 1, 10) * 5,
    med - dir * rbeta(n2, 3, 1) * 10
  )
}
rD1 <- function(n) rD(n, 20, -3)
rD2 <- function(n) rD(n, 22, 1)

# Data -------------------------------------------------------------------------
set.seed(1729)
x <- rD1(1000)
y <- rD2(1000)
N <- 10000
res <- list(
  ms = ms(x, y),
  hl = hl(x, y),
  z_mean = mean(rD2(N) - rD1(N)),
  z_median = median(rD2(N) - rD1(N))
)
print(res)

# Figures ----------------------------------------------------------------------

figure_density <- function() {
  df <- data.frame(X = x, Y = y) %>% gather("distribution", "value")
  ggplot(df, aes(value, col = distribution)) +
    geom_density(bw = "SJ") +
    geom_rug(sides = "b") +
    scale_color_manual(values = cbp$values) +
    scale_x_continuous(breaks = seq(0, 60, by = 2)) +
    labs(x = "Value", y = "Density", col = "")
}

figure_z <- function() {
  z <- rD2(N) - rD1(N)
  df_text <- data.frame(
    x = c(mean(z), median(z)),
    y = max(density(z, bw = "SJ")$y),
    label = c("Mean", "Median"),
    col = c(cbp$navy, cbp$green)
  )
  ggplot(data.frame(x = z), aes(x)) +
    geom_hline(yintercept = 0, col = cbp$grey) +
    geom_density(bw = "SJ") +
    geom_rug() +
    geom_vline(xintercept = df_text$x, col = df_text$col, size = 1.1) +
    geom_text(data = df_text,
              aes(x, y, label = label),
              col = df_text$col,
              hjust = 1.1) +
    scale_x_continuous(breaks = seq(-50, 20, by = 2)) +
    labs(x = "Y-X", y = "Density")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
