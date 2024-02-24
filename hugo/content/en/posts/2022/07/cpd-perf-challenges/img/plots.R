# Libraries
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_unload(all)
library(pacman)
## Plotting
p_load(ggplot2)
p_load(ggdark)
p_load(gridExtra)
p_load(latex2exp)
## Data management
p_load(dplyr)
p_load(plyr)
p_load(tidyr)
## Misc
p_load(Hmisc)

# Clearing the environment
rm(list = ls())

# A color palette adopted for color-blind people based on https://jfly.uni-koeln.de/color/
cbp <- list(red = "#D55E00", blue = "#56B4E9", green = "#009E73", orange = "#E69F00",
            navy = "#0072B2", pink = "#CC79A7", yellow = "#F0E442", grey = "#999999")

# ggplot helpers
ggsave_ <- function(name, plot = last_plot(), basic.theme = theme_bw(), multithemed = T, ext = "png",
                    dpi = 200, width.px = 1.5 * 1600, height.px = 1.6 * 900) {
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

# Figures

figure.classification <- function() {
  set.seed(1729)
  N <- 100
  colors <- function(c2) c(rep(cbp$blue, N / 2), rep(c2, N / 2))
  types = list(acc = "Acceleration", deg = "Degradation", unk = "???")
  df <- rbind(
    data.frame(x = 1:N, y = c(rnorm(N / 2, 20), rnorm(N / 2, 10)),
               col = colors(cbp$green), type = types$acc),
    data.frame(x = 1:N, y = c(rnorm(N / 2, 20), rnorm(N / 2, 30)),
               col = colors(cbp$red), type = types$deg),
    data.frame(x = 1:N, y = c(rnorm(N / 2, 20), sample(c(rnorm(N / 4, 10), rnorm(N / 4, 30)))),
               col = colors(cbp$pink), type = types$unk)
  )
  df.arrow <- data.frame(
    x = rep(N / 2 - 5, 4),
    y = c(17, 23, 17, 23),
    xend = rep(N / 2 + 5, 4),
    yend = c(13, 27, 13, 27),
    type = c(types$acc, types$deg, types$unk, types$unk),
    col = c(cbp$green, cbp$red, cbp$pink, cbp$pink)
  )
  df$type <- factor(df$type, levels = types)
  df.arrow$type <- factor(df.arrow$type, levels = types)
  ggplot(df, aes(x, y)) +
    geom_point(col = df$col) +
    facet_wrap(vars(type), nrow = 1) +
    geom_segment(aes(x, y, xend = xend, yend = yend), data = df.arrow,
                 arrow = arrow(length = unit(0.5, "cm")), col = df.arrow$col, size = 2) +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

figure.metadata <- function() {
  set.seed(1729)
  types <- list(m = "main branch", b = "feature branches")
  pallette <- c(cbp$red, cbp$blue)

  speed.factor <- 30
  values <- c(
    rnorm(50, 10),
    ifelse(runif(100) < exp(-(1:100)/speed.factor), rnorm(100, 10), rnorm(100, 20))
  )
  values[(5:14) * 10 + 1] <- rnorm(10, 20)

  df <- data.frame(x = 1:length(values), y = values, type = rep(c(types$m, rep(types$b, 9)), 15))
  df$type <- factor(df$type, levels = types)
  ggplot(df, aes(x, y, col = type, size = type, shape = type)) +
    geom_point() +
    geom_vline(xintercept = 50.5, linetype = "dashed", col = cbp$grey) +
    scale_color_manual(values = pallette) +
    scale_size_manual(values = c(3, 1.5)) +
    labs(x = "Build", y = "Measurement", col = "", size = "", shape = "") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.position = "bottom")
}

figure.ranking1 <- function() {
  set.seed(1729)

  N <- 400
  L1 <- 40
  R1 <- 60
  L2 <- 42
  R2 <- 62
  MID <- N / 2 + 0.5
  df <- data.frame(
    x = 1:N,
    y = c(runif(N / 2, L1, R1), runif(N / 2, L2, R2))
  )
  df.seg <- data.frame(
    x = c(0, 0, MID, MID),
    y = c(L1, R1, L2, R2),
    xend = c(MID, MID, N, N),
    yend = c(L1, R1, L2, R2)
  )
  ggplot(df, aes(x, y)) +
    geom_point(col = cbp$blue) +
    geom_vline(xintercept = MID, linetype = "longdash", col = cbp$grey) +
    geom_segment(data = df.seg, aes(x, y, xend = xend, yend = yend), linetype = "dashed", col = cbp$blue) +
    ylim(0, NA) +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

figure.ranking2 <- function() {
  set.seed(1729)

  N <- 100
  N1 <- N * 0.4
  N3 <- N1
  N2 <- N - N1 - N3
  df <- data.frame(
    x = 1:N,
    y = c(
      rnorm(N1, 10),
      ifelse(runif(N2) < 0.2, rnorm(N2, 90), rnorm(N2, 10)),
      rnorm(N3, 10)
    )
  )
  ggplot(df, aes(x, y)) +
    geom_point(col = cbp$blue) +
    ylim(0, NA) +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

figure.matching <- function() {
  set.seed(1729)

  build <- function(index, m.diff, sd.scale = 1) {
    data.frame(x = 1:100, y = c(rnorm(50, 10, 1), rnorm(50, 10 + m.diff, sd.scale)), type = paste0("Test ", index))
  }
  
  df <- rbind(
    build(1, 0),
    build(2, 5),
    build(3, 10),
    build(4, 2, 2),
    build(5, 0),
    build(6, 3, 3)
  )
  
  ggplot(df, aes(x, y)) +
    geom_point(col = cbp$blue) +
    geom_vline(xintercept = 50.5, linetype = "longdash", col = cbp$grey) +
    facet_wrap(vars(type), ncol = 3, scales = "free") +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

figure.accuracy <- function() {
  set.seed(1729)
  df <- data.frame(
    x = 1:101,
    y = c(runif(50, 10, 20), 20, runif(50, 20, 30)),
    type = c(rep("A", 50), "B", rep("A", 50))
  )
  df$type <- factor(df$type, levels = c("A", "B"))
  ggplot(df, aes(x, y, col = type, size = type, shape = type)) +
    geom_vline(xintercept = 51, linetype = "longdash", col = cbp$grey) +
    geom_point() +
    labs(x = "Build", y = "Measurement", col = "", size = "", shape = "") +
    scale_color_manual(values = c(cbp$blue, cbp$red)) +
    scale_size_manual(values = c(1.5, 3)) +
    scale_shape_manual(values = c(17, 16)) +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.position = "none")
}

figure.distance1 <- function() {
  set.seed(1729)
  df <- data.frame(
    x = 1:10,
    y = c(rnorm(5, 10), rnorm(5, 20))
  )
  ggplot(df, aes(x, y)) +
    geom_point(col = cbp$blue, size = 2) +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

figure.distance2 <- function() {
  set.seed(1729)
  df <- data.frame(
    x = 1:100,
    y = c(sapply(1:20, function(i) rnorm(5, i * 10)))
  )
  ggplot(df, aes(x, y)) +
    geom_point(col = cbp$blue, size = 1.5) +
    labs(x = "Build", y = "Measurement") +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}


# Plotting

figure.classification()
ggsave_("classification")
figure.metadata()
ggsave_("metadata")
figure.ranking1()
ggsave_("ranking1")
figure.ranking2()
ggsave_("ranking2")
figure.matching()
ggsave_("matching")
figure.distance1()
ggsave_("distance1")
figure.distance2()
ggsave_("distance2")
