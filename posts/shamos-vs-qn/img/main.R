# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Settings ---------------------------------------------------------------------
settings <- list(
  efficiency = list(
    rebuild = FALSE,
    filename = "data-efficiency.csv",
    repetitions = 100000,
    ns = 2:100
  )
)

# Data -------------------------------------------------------------------------
build_df <- function() {
  apply_settings(settings$efficiency)
  
  estimate <- function(n) {
    x <- rnorm(n)
    c(sd = sd(x), shamos = shamos.unbiased(x), qn = Qn(x))
  }
  process <- function(n) {
    x <- data.frame(t(replicate(repetitions, estimate(n))))
    data.frame(
      n = n,
      shamos = var(x$sd) / var(x$shamos),
      qn = var(x$sd) / var(x$qn)
    )
  }
  df <- multi_estimate(rebuild, filename, ns, process)
  df
}
build_df()

# Figures ----------------------------------------------------------------------
figure_eff <- function() {
  df <- build_df() %>%
    gather("estimator", "efficiency", -n)
  df$estimator <- factor(df$estimator, levels = c("shamos", "qn"))
  df$parity <- ifelse(df$n %% 2 == 0, "Even", "Odd")
  ggplot(df, aes(n, efficiency, col = estimator, shape = parity)) +
    geom_point() +
    geom_hline(yintercept = 0.86, col = cbp$green, linetype = "dotted") +
    geom_hline(yintercept = 0.8227, col = cbp$red, linetype = "dotted") +
    scale_x_continuous(breaks = seq(0, 100, by = 10)) +
    scale_y_continuous(limits = c(0, 1),
                       breaks = seq(0, 1, by = 0.1)) +
    scale_color_manual(values = c(cbp$green, cbp$red),
                       labels = c("Shamos", "Qn")) +
    labs(
      x = "Sample Size (N)",
      y = "Relative Efficiency to StdDev",
      col = "Estimator",
      shape = "Parity of N"
    ) +
    guides(color = guide_legend(order = 1), 
           shape = guide_legend(order = 2))
  
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
