library(ggplot2)
library(ggdark)
library(svglite)
library(evd)

cbPalette <- rep(c("#D55E00", "#56B4E9", "#009E73", "#E69F00", "#0072B2", "#CC79A7"), 2)

save <- function(name, plot = last_plot(), tm = theme()) {
  ggsave(paste0(tolower(name), "-light.svg"), plot + theme_gray() + tm, width = 8, height = 6)
  ggsave(paste0(tolower(name), "-dark.svg"), plot + dark_theme_gray() + tm, width = 8, height = 6)
  invert_geom_defaults()
}

segment <- function(x1, y1, x2, y2, col) geom_segment(
  data = data.frame(x1 = x1, x2 = x2, y1 = y1, y2 = y2),
  aes(x = x1, y = y1, xend = x2, yend = y2),
  col = col, linetype = "dashed")
show_value <- function(x, col) segment(x, 0, x, dgumbel(x), col)
show_text <- function(x, text, col, hjust)
  annotate("text", x = x - (hjust - 0.5) * 0.5, y = dgumbel(x), label = text, hjust = hjust, col = col)

x <- seq(-4, 7, by = 0.001)
y <- dgumbel(x)
df <- data.frame(x = x, y = y)
p <- ggplot(df, aes(x, y)) +
  geom_line() +
  ylab("PDF(x)") +
  ggtitle("Probability density function (Gumbel distribution)")
save("gumbel", p)

med <- -log(log(2)) # Median
mad0 <- 0.767049251325708 # Median absolute deviation
xm <- seq(med - mad0, med + mad0, by = 0.001)
ym <- dgumbel(xm)
xm <- c(med - mad0, xm, med + mad0)
ym <- c(0, ym, 0)
dfm <- data.frame(x = xm, y = ym)
pm <- ggplot() +
  geom_polygon(data = dfm, mapping = aes(x, y), fill = cbPalette[3], alpha = 0.3) +
  show_value(med, cbPalette[1]) +
  show_text(med, "M", cbPalette[1], 0) +
  show_value(med - mad0, cbPalette[2]) +
  show_text(med - mad0, "M-MAD", cbPalette[2], 1) +
  show_value(med + mad0, cbPalette[2]) +
  show_text(med + mad0, "M+MAD", cbPalette[2], 0) +
  geom_line(data = df, mapping = aes(x, y)) +
  annotate("text", x = med, y = dgumbel(med) / 2, label = "50%", size = 8) +
  annotate("text", x = med - mad0 * 1.7, y = dgumbel(med - mad0 * 1.7) / 4, label = "22.48%", size = 4) +
  annotate("text", x = med + mad0 * 2.1, y = dgumbel(med - mad0 * 1.7) / 4, label = "27.52%", size = 4) +
  ylab("PDF(x)") +
  ggtitle("Probability density function (Gumbel distribution)")
save("gumbel-mad", pm)
