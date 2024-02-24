# Scripts ----------------------------------------------------------------------
source("utils.R")

# Data -------------------------------------------------------------------------
df <- read.csv("data.csv")
df$durationMs <- df$durationNs / 1000000
df$index <- (df$buildId - 1) * 100 + df$iteration
df$buildId <- factor(df$buildId)

# Figures ----------------------------------------------------------------------
draw_one <- function(os, benchmark, buildIdMax = 100) {
  ggplot(df[df$os == os & df$benchmark == benchmark & as.numeric(df$buildId) <= buildIdMax,], aes(index, durationMs, col = buildId)) +
    geom_point(size = 0.5) +
    facet_grid(vars(benchmark), vars(os), scales = "free") +
    scale_color_manual(values = rep(cbp$values[1:6], 17)) +
    ylim(c(0, NA)) +
    labs(x = "Iteration", y = "Duration, ms") +
    theme(legend.position = "none")
}
draw_all <- function(buildIdMax = 100) {
  ggplot(df[as.numeric(df$buildId) <= buildIdMax,], aes(index, durationMs, col = buildId)) +
    geom_point(size = 0.5) +
    facet_grid(vars(benchmark), vars(os), scales = "free") +
    scale_color_manual(values = rep(cbp$values[1:6], 17)) +
    ylim(c(0, NA)) +
    labs(x = "Iteration", y = "Duration, ms") +
    theme(legend.position = "none")
}
figure_summary <- function() draw_all()
figure_summary20 <- function() draw_all(20)
figure_linux_cpu <- function() draw_one("linux", "Cpu")
figure_linux_memory <- function() draw_one("linux", "Memory")
figure_linux_disk <- function() draw_one("linux", "Disk")
figure_windows_cpu <- function() draw_one("windows", "Cpu")
figure_windows_memory <- function() draw_one("windows", "Memory")
figure_windows_disk <- function() draw_one("windows", "Disk")
figure_macos_cpu <- function() draw_one("macos", "Cpu")
figure_macos_memory <- function() draw_one("macos", "Memory")
figure_macos_disk <- function() draw_one("macos", "Disk")

# Plotting ---------------------------------------------------------------------
regenerate_figures()
