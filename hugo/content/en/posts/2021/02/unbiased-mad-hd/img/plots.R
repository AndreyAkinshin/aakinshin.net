library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(latex2exp)
library(knitr)

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = TRUE, ext = "png", dpi = 300) {
  width <- 1600 / dpi
  height <- 900 / dpi
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

### Basic functions
median.hd <- function(x) as.numeric(hdquantile(x, 0.5))
mad <- function(x) median(abs(x - median(x)))
mad.hd <- function(x) median.hd(abs(x - median.hd(x)))
mse <- function(predicted, true.value) sum((predicted - true.value)^2) / length(predicted)

# Park's approach for straightforward median
Park.bias <- c(
  NA, -0.163388, -0.3275897, -0.2648275, -0.178125, -0.1594213, 
  -0.1210631, -0.1131928, -0.0920658, -0.0874503, -0.0741303, -0.0711412, 
  -0.0620918, -0.060021, -0.0534603, -0.0519047, -0.0467319, -0.0455579, 
  -0.0417554, -0.0408248, -0.0376967, -0.036835, -0.0342394, -0.033539, 
  -0.0313065, -0.0309765, -0.029022, -0.0287074, -0.0269133, -0.0265451, 
  -0.0250734, -0.0248177, -0.023646, -0.0232808, -0.0222099, -0.0220756, 
  -0.0210129, -0.0207309, -0.0199272, -0.019714, -0.0188446, -0.0188203, 
  -0.0180521, -0.0178185, -0.0171866, -0.0170796, -0.0165391, -0.0163509, 
  -0.0157862, -0.0157372, -0.015282, -0.0149951, -0.0146042, -0.0145007, 
  -0.0140391, -0.0139674, -0.0136336, -0.0134819, -0.0130812, -0.0129708, 
  -0.0126589, -0.0125598, -0.0122696, -0.0121523, -0.0118163, -0.0118244, 
  -0.0115177, -0.0114479, -0.0111309, -0.0110816, -0.0108875, -0.0108319, 
  -0.0106032, -0.0105424, -0.0102237, -0.0102132, -0.0099408, -0.0099776, 
  -0.0097815, -0.0097399, -0.0094837, -0.0094713, -0.009239, -0.0092875, 
  -0.0091508, -0.0090145, -0.0088191, -0.0088205, -0.0086622, -0.0085714, 
  -0.0084718, -0.0083861, -0.0082559, -0.008265, -0.0080977, -0.0080708, 
  -0.007881, -0.0078492, -0.0077043, -0.0077614)
predict.HayesPark <- function(n) ifelse(
  n <= 100,
  qnorm(0.75) * (1 + Park.bias[n]),
  qnorm(0.75) * (1 - 0.76213 / n - 0.86413 / n^2))

# Our approach for Harrell-Davis median
df.sim <- read.csv("simulation.csv")
df.sim$bias <- 1 - df.sim$factor / qnorm(0.75)
ggplot(df.sim, aes(n, factor)) +
  geom_hline(yintercept = qnorm(0.75)) +
  geom_line(col = cbRed)
ggsave_nice("simulation")

ggplot(df.sim[df.sim$n <= 100,], aes(n, factor)) +
  geom_hline(yintercept = qnorm(0.75)) +
  geom_line(col = cbGrey, alpha = 0.5) +
  geom_point(col = cbRed, size = 0.8)
ggsave_nice("simulation100")

df.train <- df.sim[df.sim$n %% 10 == 0 & df.sim$n >= 100,]
kable(df.train[,1:2], digits = 4)
fit <- lm(bias ~ 0 + I(n^(-1)) + I(n^(-2)), data = df.train)

df.train$bias2 <- df.train$bias - 0.5 * df.train$n^(-1)
fit2 <- lm(bias2 ~ 0 + I(n^(-2)), data = df.train)

predict.factor <- function(n) ifelse(
  n <= 100,
  df.sim[n,]$factor,
  qnorm(0.75) * (1 - predict(fit, data.frame(n)))
)
predict.factor.emp <- function(n) ifelse(
  n <= 100,
  df.sim[n,]$factor,
  qnorm(0.75) * (1 - 0.5 / n - 6.5 / n^2)
)

n.test <- 100:150
df.test <- rbind(
  data.frame(n = df.sim$n, factor = df.sim$factor, type = "Simulation"),
  data.frame(n = n.test, factor = predict.factor(n.test), type = "Prediction")
)
ggplot(df.test, aes(n, factor, col = type)) +
  geom_line() +
  geom_hline(yintercept = qnorm(0.75))

df.diff <- cbind(df.sim, predict = predict.factor.emp(df.sim$n))
df.diff <- df.diff[df.diff$n > 50, ]
df.diff$diff <- abs(df.diff$factor - df.diff$predict)
df.diff[df.diff$diff == max(df.diff$diff),]

n.print <- 1:100
df.print <- data.frame(n = n.print, an = df.sim[n.print,]$factor, cn = 1 / df.sim[n.print,]$factor)
kable(df.print, digits = 5)

## MSE
mse.check <- function(n) {
  est.sf <- replicate(100000, mad(rnorm(n))) / predict.HayesPark(n)
  est.hd <- replicate(100000, mad.hd(rnorm(n))) / predict.factor(n)
  df <- rbind(
    data.frame(estimation = est.sf, type = "Straightforward"),
    data.frame(estimation = est.hd, type = "Harrell-Davis")
  )
  p <- ggplot(df, aes(estimation, fill = type)) +
    geom_density(bw = "SJ", alpha = 0.5) +
    xlim(0, 5) +
    ggtitle(paste0("MSE distribution (n = ", n, ")")) +
    theme(legend.title = element_blank()) +
    scale_fill_manual(values = cbPalette) +
    geom_vline(xintercept = 1, linetype = "dashed")
  ggsave_nice(paste0("mse", n))
  data.frame(n = n, Straightforward = mse(est.sf, 1), HarrellDavis = mse(est.hd, 1))
}

set.seed(42)
df.mse <- do.call("rbind", lapply(c(3, 4, 5, 10, 20, 30, 40, 50, 100), function(n) mse.check(n)))
kable(df.mse, digits = 3)
