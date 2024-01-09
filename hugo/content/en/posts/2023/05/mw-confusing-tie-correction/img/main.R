# Scripts ----------------------------------------------------------------------
source("utils.R")

# Functions --------------------------------------------------------------------
s <- function(xi, yj) (sign(xi - yj) + 1) / 2
mwu <- function(x, y) sum(outer(x, y, s))
draw <- function(n, m, mx) {
  rep <- 100000
  
  rF <- function(n) runif(n, 0, mx)
  rG <- function(n) floor(rF(n))
  
  uF <- replicate(rep, mwu(rF(n), rF(m)))
  uG <- replicate(rep, mwu(rG(n), rG(m)))
  df <- rbind(
    data.frame(type = "F (without ties)", u = uF),
    data.frame(type = "G (with ties)", u = uG)
  )
  ggplot(df, aes(x = u)) + 
    geom_histogram(aes(y = ..density..), binwidth = 1, col = cbp$red, fill = "transparent") +
    facet_wrap(vars(type)) +
    labs(
      title = "Distribution of the Mann-Whitney U statistic",
      x = "U",
      y = "Density"
    )
}


# Figures ----------------------------------------------------------------------
figure_nm2 <- function() draw(2, 2, 2)
figure_nm10 <- function() draw(10, 10, 1.05)

# Plotting ---------------------------------------------------------------------
regenerate_figures()
