library(changepoint.np)
library(ggplot2)
library(ggdark)
smartsave <- function(p, filename, tm) {
   ggsave(paste0(filename, "-light.png"), p + theme_gray() + tm)
   ggsave(paste0(filename, "-dark.png"), p + dark_theme_gray() + tm)
  }

set.seed(13)
k <- 1000
data <- c(
  rnorm(k, 100, 10),
  100 + rbeta(k, 1, 10) * 200,
  rnorm(k, 200, 10),
  rnorm(k, 200, 30),
  sample(c(rnorm(k / 2, 120, 10), rnorm(k / 2, 280, 10))),
  sample(c(rnorm(k / 3, 100, 10), rnorm(k / 3, 200, 10), rnorm(k / 3, 300, 10)))
)
n <- length(data)
changepoints <- cpt.np(data)@cpts
colors <- sapply(1:n, function(i) sum(i>changepoints))
df <- data.frame(x = 1:length(data), y = data, col = factor(colors))
p <- ggplot(df, aes(x = x, y = y, col = col, shape = col)) + 
  geom_point(size = 2) +
  xlab("Iteration") +
  ylab("Value")
tm <- theme(legend.position = "none")
smartsave(p, "edpelt", tm)