rm(list = ls())

x <- c(
  298, 297, 314, 312, 299, 301, 295, 295, 293, 293, 293, 293, 293, 292, 295,
  293, 295, 293, 292, 295, 293, 293, 293, 299, 295, 304, 301, 296, 327, 294,
  294, 293, 293, 293, 293, 293, 293, 292, 293, 292, 293, 294, 292, 294, 294,
  294, 293, 293, 293, 293, 292, 294, 293, 296, 294, 299, 292, 293, 293, 294,
  292, 293, 293, 292, 294, 292, 292, 293, 293, 292, 292, 292, 294, 293, 293)
yA <- c(2641,  30293,  27648)
yB <- c(2641, 175631, 532991)

mad <- function(x) median(abs(x - median(x)))
pmad <- function(x, y) {
  nx <- length(x)
  ny <- length(y)
  sqrt(((nx - 1) * mad(x)^2 + (ny - 1) * mad(y)^2) / (nx + ny - 2))
}
esCohen <- function(x, y) (median(y) - median(x)) / pmad(x, y)
esGlass <- function(x, y) (median(y) - median(x)) / mad(x)

esCohen(x, yA)
esCohen(x, yB)
esGlass(x, yA)
esGlass(x, yB)