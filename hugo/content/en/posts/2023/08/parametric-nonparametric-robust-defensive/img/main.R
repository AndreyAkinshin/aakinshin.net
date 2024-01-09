# Scripts ----------------------------------------------------------------------
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_compare <- function(dark_mode = FALSE) {
  types <- c(
    "Parametric",
    "Nonparametric",
    "Robust",
    "Defensive"
  )
  gr <- function(level) if (dark_mode) gray(1 - level) else gray(level)
  xL <- -3
  xR <- 3
  yL <- 0
  yR <- dnorm(0) + 0.1
  xs <- seq(xL, xR, by = 0.01)
  ys <- dnorm(xs)
  dst <- function(x, y) min(sqrt((xs - x)^2 + (ys - y)^2))
  
  df_d <- expand.grid(
    x = seq(xL, xR, length.out = 16 * 4),
    y = seq(yL, yR, length.out = 9 * 4),
    color = gr(0),
    size = 0.1
  )
  df_d$dist <- sapply(1:nrow(df_d), function(i) dst(df_d$x[i], df_d$y[i]))
  
  df_d2 <- df_d
  df_d2$type <- types[2]
  
  df_d3 <- df_d[df_d$dist < 0.05, ]
  df_d3$type <- types[3]
  
  df_d4 <- df_d
  df_d4$size <- (1 - df_d$dist / max(df_d$dist)) ^ 1.2
  df_d4$color <- gr((1 - df_d4$size) * 0.8)

  df_d4$type <- types[4]
  
  df_dd <- rbind(df_d2, df_d3, df_d4)
  df_dd$type <- factor(df_dd$type, levels = types)
  
  df <- rbind(
    data.frame(x = xs, y = ys, type = types[1]),
    data.frame(x = xs, y = ys, type = types[3]),
    data.frame(x = xs, y = ys, type = types[4])
  )
  df$type <- factor(df$type, levels = types)

  ggplot(df, aes(x, y)) +
    geom_line() +
    geom_point(data = df_dd, aes(color = color, size = size)) +
    scale_color_identity() +
    scale_size_identity() +
    facet_wrap(vars(type), nrow = 2) +
    theme_void() +
    theme(strip.text = element_text(size = 20, color = gr(0)))
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
