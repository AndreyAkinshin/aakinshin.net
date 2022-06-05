library(htmlwidgets)
library(ggdark)

source("../src/main.R")

ggsave_niceSq <- function(name, plot = last_plot(), tm = theme_bw(), dark_and_light = T, ext = "png", dpi = 300) {
  width <- 1.5 * 1600 / dpi
  height <- 1.5 * 1600 / dpi
  folder <- "../img/"
  if (dark_and_light) {
    old_theme <- theme_set(tm)
    ggsave(paste0(folder, name, "-light.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(dark_mode(tm, verbose = FALSE))
    ggsave(paste0(folder, name, "-dark.", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(tm)
    ggsave(paste0(folder, name, ".", ext), plot, width = width, height = height, dpi = dpi)
    theme_set(old_theme)
  }
}
plotlySave <- function(name, plot) {
  saveWidget(plot, paste0("../frames/", name, ".html"), selfcontained = F, libdir = "files")
}

s1p1 <- draw.simple(traj1)
ggsave_niceSq("sim1-simple", s1p1)
s1p2 <- draw.speed(traj1)
ggsave_niceSq("sim1-color", s1p2)
s1p3 <- draw.3d(traj1)
plotlySave("sim1", s1p3)

s2p1 <- draw.simple(traj2)
ggsave_niceSq("sim2-simple", s2p1)
s2p2 <- draw.speed(traj2)
ggsave_niceSq("sim2-color", s2p2)
s2p3 <- draw.3d(traj2)
plotlySave("sim2", s2p3)

s3p1 <- draw.simple(traj3)
ggsave_niceSq("sim3-simple", s3p1)
s3p2 <- draw.speed(traj3)
ggsave_niceSq("sim3-color", s3p2)
s3p3 <- draw.3d(traj3)
plotlySave("sim3", s3p3)
