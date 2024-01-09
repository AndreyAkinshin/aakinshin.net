library(effsize)
library(Hmisc)
library(tidyr)
library(ggplot2)
library(ggdark)
library(svglite)
library(plyr)
library(dplyr)
library(latex2exp)
library(knitr)
library(stringr)
library(jsonlite)

### Helpers

cbRed <- "#D55E00"; cbBlue <- "#56B4E9"; cbGreen <- "#009E73"; cbOrange <- "#E69F00"
cbNavy <- "#0072B2"; cbPink <- "#CC79A7"; cbYellow <- "#F0E442"; cbGrey <- "#999999"
cbPalette <- c(cbRed, cbBlue, cbGreen, cbOrange, cbNavy, cbPink, cbYellow, cbGrey)
ggsave_nice <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 200) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 900 / dpi
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
as.sorted.factor <- function(c) factor(c, levels = as.vector(unique(c)))

### Reading

dataDir <- "../data/"
files <- list.files(dataDir, "*.json.gz")
jsons <- lapply(files, function(f) fromJSON(gzfile(paste0(dataDir, f))))
df <- do.call("rbind", jsons) # Data Frame with error distributions

### Transforming

baselineEstimator <- "HF7"
efficienyThreshold <- 3
df$estimator <- as.sorted.factor(df$estimator)
df$distribution <- as.sorted.factor(df$distribution)
df$probability <- as.numeric(df$probability)
df$mse <- as.numeric(df$mse)

df <- df %>% plyr::mutate(baseMse = df[
  df$probability == probability &
    df$sampleSize == sampleSize &
    df$distribution == distribution &
    df$estimator == baselineEstimator,]$mse)

df$efficiency <- df$baseMse / df$mse
df$efficiency.exceed <- df$efficiency > efficienyThreshold
df$efficiency <- pmin(df$efficiency, efficienyThreshold)

### Plotting

columnCount <- 5
draw <- function(n) {
  p <- ggplot(
    df %>% filter(sampleSize == n & estimator != baselineEstimator),
    aes(x = probability, y = efficiency, col = estimator)) +
    geom_hline(yintercept = 1, linetype = "dotted") +
    geom_line(alpha = 1) +
    #geom_point(size = 1, aes(shape = efficiency.exceed)) +
    facet_wrap(vars(distribution), ncol = columnCount) +
    scale_x_continuous(limits = c(0, 1)) +
    scale_color_manual(values = cbPalette) +
    scale_shape_manual(values = c(16, 8), guide = F) +
    ggtitle(paste0("Relative efficiency of quantile estimators (n = ", n, ")")) +
    ylim(0, efficienyThreshold)
  show(p)
  ggsave_nice(paste0("Efficiency_N", str_pad(n, 2, pad = "0")), p)
}
for (n in unique(df$sampleSize))
#for (n in c(3, 5, 10, 20, 40))
  draw(n)