getBetaHdi <- function(a, b, width) {
  eps <- 1e-9
  if (a < 1 + eps & b < 1 + eps) # Degenerate case
    return(c(NA, NA))
  if (a < 1 + eps & b > 1) # Left border case
    return(c(0, width))
  if (a > 1 & b < 1 + eps) # Right border case
    return(c(1 - width, 1))

  # Middle case
  mode <- (a - 1) / (a + b - 2)
  pdf <- function(x) dbeta(x, a, b)

  l <- uniroot(
    f = function(x) pdf(x) - pdf(x + width),
    lower = max(0, mode - width),
    upper = min(mode, 1 - width)
    )$root
  r <- l + width
  return(c(l, r))
}
