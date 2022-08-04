# Libraries

## Init pacman
suppressMessages(if (!require("pacman")) install.packages("pacman"))
suppressMessages(p_unload(all))
library(pacman)

## Plotting
p_load(ggplot2)
p_load(ggdark)
p_load(ggpubr)
p_load(gridExtra)
p_load(latex2exp)

## Data manipulation
p_load(dplyr)
p_load(plyr)
p_load(tidyr)

## Misc
p_load(Hmisc)
p_load(knitr)
p_load(robustbase)
p_load(Rfast)
p_load(rtern)

#-------------------------------------------------------------------------------
# Preparation

## Clear the environment
rm(list = ls())

# Source
source("mad-factors.R")

## A color palette adopted for color-blind people based on https://jfly.uni-koeln.de/color/
cbp <- list(
  red = "#D55E00", blue = "#56B4E9", green = "#009E73", orange = "#E69F00",
  navy = "#0072B2", pink = "#CC79A7", yellow = "#F0E442", grey = "#999999"
)
cbp$values <- unname(unlist(cbp))

## A smart ggsave wrapper
ggsave_ <- function(name, plot = last_plot(), basic.theme = theme_bw(), multithemed = TRUE, ext = "png",
                    dpi = 300, width.px = 1.5 * 1600, height.px = 1.6 * 900) {
  if (class(name) == "function") {
    plot <- name()
    name <- as.character(match.call()[2])
    if (startsWith(name, "figure.")) {
      name <- substring(name, nchar("figure.") + 1)
    }
  }

  width <- width.px / dpi
  height <- height.px / dpi
  if (multithemed) {
    old_theme <- theme_set(basic.theme)
    ggsave(paste0(name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(basic.theme, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(basic.theme)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}

#-------------------------------------------------------------------------------
# Functions

os <- function(x, k) x[kit::topn(x, k, decreasing = F)[k]] # Order statistic
lmedian <- function(x) os(x, floor((length(x) + 1) / 2)) # Low median
hmedian <- function(x) os(x, floor(length(x) / 2) + 1) # High median

c4 <- function(n) ifelse(n < 300, sqrt(2 / (n - 1)) * gamma(n / 2) / gamma((n - 1) / 2), 1)
sd.unbiased <- function(x) sd(x) / c4(length(x))

sn <- function(x) {
  n <- length(x)
  y <- rep(0, n)
  for (i in 1:n) {
    y[i] <- hmedian(abs(x[i] - x))
  }
  cn <- ifelse(n <= 9,
    c(NA, 0.743, 1.851, 0.954, 1.351, 0.993, 1.198, 1.005, 1.131)[n],
    ifelse(n %% 2 == 0, 1, n / (n - 0.9))
  )
  cn * 1.1926 * lmedian(y)
}
qn <- function(x) {
  n <- length(x)
  df <- expand.grid(i = 1:n, j = 1:n)
  df <- df[df$i < df$j, ]
  df$r <- abs(x[df$i] - x[df$j])
  k <- choose(n %/% 2 + 1, 2)
  dn <- ifelse(n <= 9,
    c(NA, 0.399, 0.994, 0.512, 0.844, 0.611, 0.857, 0.669, 0.872)[n],
    ifelse(n %% 2 == 0, n / (n + 3.8), n / (n + 1.4))
  )
  dn / (sqrt(2) * qnorm(5 / 8)) * os(df$r, k)
}

estimate <- function(x) {
  c(
    n = length(x),
    sd = sd.unbiased(x),
    mad = mad.sm(x),
    sn = Sn(x),
    qn = Qn(x)
  )
}

#-------------------------------------------------------------------------------
# Data

build.df <- function() {
  filename.bias <- "data-bias.csv"
  filename.eff <- "data-eff.csv"
  df.bias <- file.exists(filename.bias) ? read.csv(filename.bias) : data.frame()
  df.eff <- file.exists(filename.eff) ? read.csv(filename.eff) : data.frame()

  ns <- sort(c(3:51, seq(60, 200, by = 10), seq(60, 200, by = 10) + 1))
  ns.new <- ns[!(ns %in% unique(df.eff$n))]
  if (length(ns.new) == 0) {
    return(list(bias = df.bias, eff = df.eff))
  }

  REP <- 5 * 1000 * 1000 # 5_000_000 ~ 8.5h

  start.time <- Sys.time()
  for (n in ns.new) {
    set.seed(1729 + n)
    start.time.n <- Sys.time()
    df.n <- data.frame(t(replicate(REP, estimate(rnorm(n)))))

    df.bias.n <- df.n %>%
      group_by(n) %>%
      summarise_all(mean) %>%
      data.frame()
    df.bias.n <- round(df.bias.n, 5)

    df.eff.n <- df.n %>%
      group_by(n) %>%
      summarise_all(var) %>%
      data.frame()
    df.eff.n[, c("mad", "qn", "sn")] <- df.eff.n[, "sd"] / df.eff.n[, c("mad", "qn", "sn")]
    df.eff.n <- round(df.eff.n %>% subset(select = -c(sd)), 5)

    df.bias <- rbind(df.bias, df.bias.n)
    df.eff <- rbind(df.eff, df.eff.n)
    file.copy(filename.bias, paste0("copy-", filename.bias), overwrite = TRUE)
    file.copy(filename.eff, paste0("copy-", filename.eff), overwrite = TRUE)
    write.csv(df.bias, filename.bias, quote = FALSE, row.names = FALSE)
    write.csv(df.eff, filename.eff, quote = FALSE, row.names = FALSE)

    message(paste0("n = ", n, ": DONE (elapsed: ", format(Sys.time() - start.time.n), ")"))
  }
  message(paste0("Total simulation duration: ", format(Sys.time() - start.time)))
  return(list(bias = df.bias, eff = df.eff))
}

dfs <- build.df()
df.bias <- dfs$bias
df.eff <- dfs$eff

df.eff2 <- df.eff %>% gather("type", "value", -n)
df.eff2$type <- factor(df.eff2$type, levels = c("mad", "sn", "qn"))
df.eff2$parity <- factor(ifelse(df.eff2$n %% 2 == 0, "Even", "Odd"), levels = c("Even", "Odd"))
df.eff2.small <- df.eff2[df.eff2$n <= 30, ]

#-------------------------------------------------------------------------------
# Tables

table.eff <- function() {
  kable(df.eff)
}

#-------------------------------------------------------------------------------
# Figures

figure.eff30 <- function() {
  ggplot(df.eff2.small, aes(n, value, col = type, shape = parity, linetype = parity)) +
    geom_line(alpha = 0.3) +
    geom_point() +
    labs(
      title = "Relative efficiency of MADn, Sn, Qn against StdDev (n <= 30)",
      x = "Sample size",
      y = "Relative efficiency",
      col = "Estimator",
      shape = "Parity",
      linetype = "Parity"
    ) +
    scale_color_manual(values = cbp$values, labels = c("MADn", "Sn", "Qn")) +
    scale_x_continuous(breaks = unique(df.eff2.small)$n)
}

figure.eff <- function() {
  ggplot(df.eff2, aes(n, value, col = type, shape = parity, linetype = parity)) +
    geom_line(alpha = 0.3) +
    geom_point(size = 1) +
    labs(
      title = "Relative efficiency of MADn, Sn, Qn against StdDev",
      x = "Sample size",
      y = "Relative efficiency",
      col = "Estimator",
      shape = "Parity",
      linetype = "Parity"
    ) +
    scale_color_manual(values = cbp$values, labels = c("MADn", "Sn", "Qn"))
}

#-------------------------------------------------------------------------------
# Plotting

## Remove all existing images
for (file in list.files()) {
  if (endsWith(file, ".png")) {
    file.remove(file)
  }
}

## Draw all the defined figures
for (func in lsf.str()) {
  if (startsWith(func, "figure.")) {
    name <- substring(func, nchar("figure.") + 1)
    ggsave_(name, get(func)())
  }
}
