library(ggplot2)
library(ggdark)
library(svglite)
library(gridExtra)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 2)

save <- function(name, plot = last_plot(), tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), plot + theme_gray() + tm, width = 8, height = 4.5)
  ggsave(paste0(tolower(name), "-dark.svg"), plot + dark_theme_gray() + tm, width = 8, height = 4.5)
  invert_geom_defaults()
}

save2 <- function(name, p1, p2, tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(p1 + theme_gray() + tm, p2 + theme_gray() + tm, nrow = 1), width = 8, height = 4.5)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(p1 + dark_theme_gray() + tm, p2 + dark_theme_gray() + tm, nrow = 1), width = 8, height = 4.5)
  invert_geom_defaults()
}

save3 <- function(name, p1, p2, p3, tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), 
         grid.arrange(
           p1 + theme_gray() + tm,
           p2 + theme_gray() + tm,
           p3 + theme_gray() + tm,
           nrow = 1),
         width = 8, height = 4.5)
  ggsave(paste0(tolower(name), "-dark.svg"),
         grid.arrange(
           p1 + dark_theme_gray() + tm,
           p2 + dark_theme_gray() + tm,
           p3 + dark_theme_gray() + tm,
           nrow = 1),
         width = 8, height = 4.5)
  invert_geom_defaults()
}

niceHist <- function(x, binwidth, breaks, max.y = -1, displacement = 0, rug = F, outline.factor = 1, title = "", kde = F) {
  mapping <- aes(x)
  if (kde)
    mapping <- aes(x, y = ..density..)
  p <- ggplot(data.frame(x = x + displacement), mapping) +
    geom_histogram(binwidth = binwidth, fill = cbPalette[1], col = "black", alpha = 0.5, size = 2 * outline.factor) +
    scale_x_continuous(breaks = breaks + displacement, labels = breaks, limits = range(breaks + displacement))
  if (max.y > 0 && !kde)
    p <- p + ylim(0, max.y + 0.5)
  if (title != "")
    p <- p + ggtitle(title)
  if (kde)
    p <- p + geom_density(bw = "SJ", fill = cbPalette[2], alpha = 0.5, col = "black")
  if (rug)
    p <- p + geom_rug(
      data = data.frame(x = x + displacement),
      mapping = aes(x),
      col = cbPalette[2],
      size = 1.5 * outline.factor)
  return(p)
}

n <- 4
set.seed(42)
x <- c(sapply(1:n, function(i) rnorm(16, sd = 0.1) + i * 10 + 10))
p1 <- niceHist(x, 5, seq(15, 55, by = 5), 16, -2.5)
p2 <- niceHist(x, 5, seq(15, 55, by = 5), 16)
save2("hist-riddle", p1, p2)

niceHist(x, 5, seq(15, 55, by = 5), 16, -2.5, kde = T)
save("hist-riddle-kde")
niceHist(x, 5, seq(15, 55, by = 5), 16, -2.5, rug = T)
save("hist-riddle-rug")

x <- c(1.1, 2.1, 2.2, 2.3, 3.1, 3.2)
niceHist(x, 1, seq(0.5, 3.5, by = 0.5), 3, rug = T)
save("hist-simple")

x <- c(18, 19, 21, 22, 38, 39, 41, 42)
niceHist(x, 10, seq(10, 50, by = 5), 4, 0, rug = T)
save("hist-offset1")
niceHist(x, 10, seq(10, 50, by = 5), 4, -5, rug = T)
save("hist-offset2")

x <- c(18, 19, 21, 22, 38, 39, 41, 42, 53, 54, 56, 57)
p1 <- niceHist(x, 10, seq(10, 65, by = 5), 5, 0, rug = T)
p2 <- niceHist(x, 10, seq(10, 65, by = 5), 5, -5, rug = T)
save2("hist-offset3", p1, p2)

set.seed(42)
x <- c(rnorm(100, 20, 2), rnorm(100, 30, 2))
p1 <- niceHist(x, 10, seq(10, 40, by = 5), displacement = 5, rug = T, title = "Oversmoothing")
p2 <- niceHist(x, 2, seq(10, 40, by = 5), rug = T, title = "What we actually want")
p3 <- niceHist(x, 0.2, seq(10, 40, by = 5), rug = T, outline.factor = 0.1, title = "Undersmoothing")
save3("hist-bandwidth1", p1, p2, p3)
