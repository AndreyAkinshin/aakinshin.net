# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
n <- 4 # Sample size

# Median absolute deviation
mad <- function(x) median(abs(x - median(x)))
# Standard deviation correction
c4 <- function(n) sqrt(2 / (n - 1)) * gamma(n / 2) / gamma((n - 1) / 2)
c4n <- c4(n)

# Data -------------------------------------------------------------------------
if (file.exists("data.csv")) {
  C_df <- read.csv("data.csv")
  CA <- C_df[1,1]
  CB <- C_df[2,1]
  CC <- C_df[3,1]
} else {
  m <- 1000000
  set.seed(42)
  CA <- 1 / mean(replicate(m, mad(rnorm(n))))
  CB <- sqrt(1 / mean(replicate(m, mad(rnorm(n))^2)))
  CC <- c4(n) / mean(replicate(m, mad(rnorm(n))))
  C_df <- data.frame(C = c(CA, CB, CC))
  write.csv(C_df, "data.csv", row.names = FALSE, quote = FALSE)
}

set.seed(1729)
estimations <- function() {
  x <- rnorm(n)
  c(sd = sd(x), mad = mad(x))
}
df <- data.frame(t(replicate(500000, estimations())))
df$madA <- CA * df$mad
df$madB <- CB * df$mad
df$madC <- CC * df$mad
df <- subset(df, select = -c(mad))

df <- df %>% gather("estimator", "value")
df$estimator <- factor(df$estimator, levels = c("sd", "madA", "madB", "madC"))
df_mean <- df %>% group_by(estimator) %>% summarise(mean = mean(value)) %>% data.frame()

df2 <- df
df2$value <- df2$value^2
df2_mean <- df2 %>% group_by(estimator) %>% summarise(mean = mean(value)) %>% data.frame()

df_summary <- data.frame(
  type = c("SD", "(A) MAD", "(B) MAD", "(C) MAD"),
  factor = c(NA, CA, CB, CC),
  e = df_mean[1:4, 2],
  e2 = df2_mean[1:4, 2]
)


# Figures ----------------------------------------------------------------------
figure_e1 <- function() {
  ggplot(df %>% gather("estimator", "value"), aes(value, col= estimator)) +
    geom_density(bw = "SJ") +
    geom_vline(data = df_mean, aes(xintercept = mean, col = estimator)) + 
    labs(x = "Estimation", y = "Density", col = "Estimator") +
    scale_color_manual(
      values = cbp$values,
      labels = c("SD", "(A) MAD", "(B) MAD", "(C) MAD")
    )
}

figure_e2 <- function() {
  ggplot(df2 %>% gather("estimator", "value"), aes(value, col= estimator)) +
    geom_density(bw = "SJ") +
    geom_vline(data = df2_mean, aes(xintercept = mean, col = estimator)) + 
    labs(x = "Estimation", y = "Density", col = "Estimator") +
    xlim(0, 5) +
    scale_color_manual(
      values = cbp$values,
      labels = c("SD^2", "(A) MAD^2", "(B) MAD^2", "(C) MAD^2")
    )
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
