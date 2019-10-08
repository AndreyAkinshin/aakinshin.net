library(ggplot2)

n <- 30 # Number of values in each sample
m <- 30 # Number of samples
k <- 16 # Number of CLT distributions

set.seed(159)
# Generate a single random value from a "strange" distribution
gen.value <- function()
  sample(1:10, 1) +                               # Offset
  rbeta(1, 1, 10) * sample(1:10, 1) +             # Right-skewed distribution
  sample(c(rep(0, 50), 1:10)) * rnorm(1, 200, 10) # Outliers
# Generate a sample mean
gen.mean <- function() mean(sapply(1:n, function(x) gen.value()))

df <- data.frame()
for (i in 1:k) {
  df <- rbind(df, data.frame(
    Experiment = rep(i, m),
    Time = sapply(1:m, function(j) gen.mean()))
  )
}
p <- ggplot(df, aes(x = Time, group = Experiment)) +
  geom_density(fill = "red", alpha = 0.4, bw = "SJ") +
  facet_wrap(~Experiment) +
  ylab("Density")

library(ggdark)
smartsave <- function(p, filename) {
  ggsave(paste0(filename, "-light.png"), p + theme_gray())
  ggsave(paste0(filename, "-dark.png"), p + dark_theme_gray())
  invert_geom_defaults()
}
smartsave(p, "clt")
