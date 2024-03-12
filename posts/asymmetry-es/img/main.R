# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Figures ----------------------------------------------------------------------
figure_density <- function() {
  hl <- function(x, y = NULL) {
    if (is.null(y)) {
      walsh <- outer(x, x, "+") / 2
      median(walsh[lower.tri(walsh, diag = TRUE)])
    } else {
      median(outer(x, y, "-"))
    }
  }
  sh <- function(x) shamos.unbiased(x)
  
  set.seed(1729)
  x0 <- rexp(5000) * 3
  hl0 <- 1
  xA <- x0 - hl(x0) - hl0
  yA <- -xA
  xB <- -xA - 2
  yB <- -xB

  df <- rbind(
    data.frame(x = xA, type = "X", group = "A"),
    data.frame(x = yA, type = "Y", group = "A"),
    data.frame(x = xB, type = "X", group = "B"),
    data.frame(x = yB, type = "Y", group = "B")
  )
  ggplot(df, aes(x, fill = type)) +
    geom_density(bw = "SJ", alpha = 0.5) +
    geom_rug(mapping = aes(col = type), sides = "b", linewidth = 0.01) +
    scale_color_manual(values = cbp$values) +
    facet_wrap(vars(group), ncol = 1) +
    scale_x_continuous(breaks = -10:10, limits = c(-10, 10)) +
    labs(fill = "", col = "", x = "Measurements", y = "Density") +
    geom_vline(xintercept = -1, col = cbp$values[1], linewidth = 2) +
    geom_vline(xintercept = +1, col = cbp$values[2], linewidth = 2)
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
