library(evd)
library(Hmisc)

# Setting seed for rgumbel to achieve deterministic result
set.seed(38)
# Harrell-Davis-powered median
hdmedian <- function(x) as.numeric(hdquantile(x, 0.5))
# MAD value which is based on the Harrell-Davis-powered median
hdmad <- function(x) hdmedian(abs(x - hdmedian(x)))
# 1000 trails of MAD estimating for a sample from the Gubmel distribution
mads <- sapply(1:1000, function(i) hdmad(rgumbel(1000)))
# Print median of all trials
hdmedian(mads)