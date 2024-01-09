# Scripts ----------------------------------------------------------------------
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
)

# Functions --------------------------------------------------------------------
hdmedian <- function(x) as.numeric(hdquantile(x, 0.5))
hl <- function(x) {
  n <- length(x)
  dfij <- expand.grid(i = 1:n, j = 1:n)
  dfij <- dfij[dfij$i < dfij$j,]
  median((x[dfij$i] + x[dfij$j]) / 2)
}
xk <- function(n, k) c(rep(0, k), rep(1, n - k))
R <- function(estimator, n, s, k) abs(estimator(xk(n, k)) - estimator(xk(n, k - s)))
RR <- function(estimator, n, s) max(sapply(s:n, function(k) R(estimator, n, s, k)))

helper_figure_resistance_hl <- function(n) {
  df <- expand.grid(s = 1:6, k = 1:n) %>% filter(s <= k)
  df$r <- pmap_dbl(df, function(s, k) R(hl, n, s, k))
  df$c <- df$r
  df$c <- factor(df$c, levels = c(0, 0.5, 1))
  ggplot(df, aes(k, r, col = c)) +
    facet_wrap(vars(s), ncol = 3, labeller = label_both) +
    geom_point() +
    scale_x_continuous(breaks = pretty(1:n)) +
    scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
    scale_color_manual(values = c(cbp$green, cbp$blue, cbp$red)) +
    theme(legend.position = "none") +
    labs(
      title = paste0("R(HL, n = ", n, ", s, k)"),
      y = "R"
    )
}

helper_figure_resistance_all <- function(n) {
  build_df <- function(title, estimator) {
    df <- expand.grid(s = 1:2, k = 1:n) %>% filter(s <= k)
    df$r <- pmap_dbl(df, function(s, k) R(estimator, n, s, k))
    df$estimator <- title
    df
  }
  df <- rbind(
    build_df("Mean", mean),
    build_df("Median", median),
    build_df("HD-Median", hdmedian),
    build_df("HL", hl)
  )
  df$estimator <- factor(df$estimator, levels = c("Mean", "Median", "HD-Median", "HL"))
  ggplot(df, aes(k, r, col = r)) +
    facet_grid(vars(s), vars(estimator), labeller = labeller(.rows = label_both, .cols = label_value)) +
    geom_point() +
    scale_x_continuous(breaks = pretty(1:n)) +
    scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
    scale_colour_gradientn(colours = c(cbp$green, cbp$blue, cbp$red)) +
    theme(legend.position = "none") +
    labs(
      title = paste0("R(T, n = ", n, ", s, k)"),
      y = "R"
    )
}


# Figures ----------------------------------------------------------------------
figure_resistance <- function() {
  build_df <- function(title, estimator, s) {
    ns <- max(2, s):100
    data.frame(
      title = title,
      n = ns,
      s = s,
      r = sapply(ns, function(n) RR(estimator, n, s))
    )
  }
  
  build_df2 <- function(title, estimator) {
    ss <- 1:6
    do.call("rbind", lapply(ss, function(s) build_df(title, estimator, s)))
  }
  
  df <- rbind(
    build_df2("Mean", mean),
    build_df2("Median", median),
    build_df2("HD-Median", hdmedian),
    build_df2("HL", hl)
  )
  ggplot(df, aes(n, r, col = title)) +
    facet_wrap(vars(s), ncol = 3, labeller = label_both) +
    geom_line() +
    scale_color_manual(values = cbp$values) +
    labs(title = "Resistance to the low density regions",
         col = "Estimator",
         x = "Sample size (n)",
         y = "Resistance function") +
    theme(legend.position = "bottom")
}

figure_resistance_hl49 <- function() helper_figure_resistance_hl(49)
figure_resistance_hl50 <- function() helper_figure_resistance_hl(50)
figure_resistance_hl99 <- function() helper_figure_resistance_hl(99)
figure_resistance_hl100 <- function() helper_figure_resistance_hl(100)

figure_resistance_all49 <- function() helper_figure_resistance_all(49)
figure_resistance_all50 <- function() helper_figure_resistance_all(50)
figure_resistance_all99 <- function() helper_figure_resistance_all(99)
figure_resistance_all100 <- function() helper_figure_resistance_all(100)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
