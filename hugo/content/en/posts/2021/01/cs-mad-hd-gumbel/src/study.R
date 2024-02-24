library(dplyr)
library(tidyr)
library(Hmisc)
library(evd)

t7mad <- function(x) quantile(abs(x - quantile(x, 0.5)), 0.5)
hdmad <- function(x) hdquantile(abs(x - hdquantile(x, 0.5)), 0.5)

build.df <- function(mad.true, gen, iterations) {
  ns <- 3:100
  df <- data.frame(
    SampleSize = rep(ns, each = iterations),
    Type7 = 0,
    HarrellDavis = 0
  )
  for (i in 1:nrow(df)) {
    x <- gen(df[i, "SampleSize"])
    df[i, "Type7"] <- abs(mad.true - t7mad(x))
    df[i, "HarrellDavis"] <- abs(mad.true - hdmad(x))
  }
  df
}

set.seed(42)
iterations <- 1000
df <- build.df(0.767049251325708, function(n) rgumbel(n), iterations)

stats <- df %>%
  group_by(SampleSize) %>%
  dplyr::summarise(
    score = sum(HarrellDavis < Type7) / iterations,
    low = prop.test(sum(HarrellDavis < Type7), n(), conf.level = 0.999, correct = F)$conf.int[1],
    high = prop.test(sum(HarrellDavis < Type7), n(), conf.level = 0.999, correct = F)$conf.int[2]
    )
