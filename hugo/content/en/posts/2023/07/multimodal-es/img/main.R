# Scripts ----------------------------------------------------------------------
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_multimodal <- function() {
  set.seed(1729)
  x1 <- c(rnorm(100, 10), rnorm(100, 120))
  x2 <- c(rnorm(100, 20), rnorm(100, 130))
  df <- rbind(
    data.frame(x = x1, type = "X"),
    data.frame(x = x2, type = "Y")
  )
  df$type <- factor(df$type, levels = c("X", "Y"))
  ggplot(df, aes(x)) +
    geom_density(bw = "SJ") +
    facet_wrap(vars(type), ncol = 1) +
    scale_x_continuous(limits = c(0, 140), breaks = seq(0, 140, by = 10))
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
