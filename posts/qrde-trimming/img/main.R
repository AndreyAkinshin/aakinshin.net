# Scripts ----------------------------------------------------------------------
wd <- getSrcDirectory(function(){})[1]
if (wd == "") wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (wd != "") setwd(wd)
source("utils.R")

# Functions --------------------------------------------------------------------
#' Kish's effective sample size
kish_ess <- function(w) sum(w)^2 / sum(w^2)

#' Weighted generic quantile estimator
wquantile_generic <- function(x, w, probs, cdf) {
  n <- length(x)
  if (is.null(w)) {
    w <- rep(1 / n, n)
  }
  if (any(is.na(x))) {
    w <- w[!is.na(x)]
    x <- x[!is.na(x)]
  }
  
  nw <- kish_ess(w)
  
  indexes <- order(x)
  x <- x[indexes]
  w <- w[indexes]
  
  w <- w / sum(w)
  t <- cumsum(c(0, w))
  
  sapply(probs, function(p) {
    if (p > 1 - 1e-9)
      return(max(x))
    if (p < 1e-9)
      return(min(x))
    cdf_values <- cdf(nw, p, t)
    W <- tail(cdf_values, -1) - head(cdf_values, -1)
    return(sum(W * x))
  })
}

#' Weighted Harrell-Davis quantile estimator
whdquantile <- function(x, w, probs) {
  cdf <- function(n, p, t) {
    if (p == 0 || p == 1)
      return(rep(NA, length(t)))
    pbeta(t, (n + 1) * p, (n + 1) * (1 - p))
  }
  wquantile_generic(x, w, probs, cdf)
}

#' Weighted trimmed Harrell-Davis quantile estimator
wthdquantile <- function(x, w, probs, width = 1 / sqrt(kish_ess(w)))
  sapply(probs, function(p) {
    getBetaHdi <- function(a, b, width) {
      eps <- 1e-9
      if (a < 1 + eps & b < 1 + eps) # Degenerate case
        return(c(NA, NA))
      if (a < 1 + eps & b > 1) # Left border case
        return(c(0, width))
      if (a > 1 & b < 1 + eps) # Right border case
        return(c(1 - width, 1))
      if (width > 1 - eps)
        return(c(0, 1))
      
      # Middle case
      mode <- (a - 1) / (a + b - 2)
      pdf <- function(x) dbeta(x, a, b)
      
      l <- uniroot(
        f = function(x) pdf(x) - pdf(x + width),
        lower = max(0, mode - width),
        upper = min(mode, 1 - width),
        tol = 1e-9
      )$root
      r <- l + width
      return(c(l, r))
    }
    
    nw <- kish_ess(w)
    a <- (nw + 1) * p
    b <- (nw + 1) * (1 - p)
    hdi <- getBetaHdi(a, b, width)
    hdiCdf <- pbeta(hdi, a, b)
    cdf <- function(n, p, t) {
      if (p == 0 || p == 1)
        return(rep(NA, length(t)))
      t[t <= hdi[1]] <- hdi[1]
      t[t >= hdi[2]] <- hdi[2]
      (pbeta(t, a, b) - hdiCdf[1]) / (hdiCdf[2] - hdiCdf[1])
    }
    wquantile_generic(x, w, p, cdf)
  })

#' Jittering of the tied values
#' @param x sample
#' @param resolution resolution of the measurements
lowland_jitter <- function(x, resolution) {
  x <- sort(x)
  n <- length(x)
  # Searching for intervals [i;j] of tied values
  i <- 1
  while (i <= n) {
    j <- i
    while (j < n && x[j + 1] - x[i] < resolution / 2) {
      j <- j + 1
    }
    if (i < j && j - i + 1 < n) {
      k <- j - i + 1
      u <- 0:(k - 1) / (k - 1)
      xi <- u - 0.5
      if (i == 1)
        xi <- u / 2
      if (j == n)
        xi <- (u - 1) / 2
      if (i == 1 && j == n)
        xi <- u - 0.5
      x[i:j] <- x[i:j] + xi * resolution
      
    }
    i <- j + 1
  }
  return(x)
}

lowland <- function(x,
                    w = NA,
                    sensitivity = 0.5,
                    bincount = 1000,
                    trim = 1,
                    qe = whdquantile,
                    resolution = NA,
                    jitter = lowland_jitter) {
  # TODO: min length check
  x0 <- x
  if (any(is.na(w)))
    w <- rep(1, length(x))
  
  # Auxiliary functions
  first <- function(x) head(x, 1)
  last <- function(x) tail(x, 1)
  
  # Jittering
  if (is.na(resolution)) {
    if (length(x) > 1) {
      xSorted <- sort(x)
      deltas <- tail(xSorted, -1) - head(xSorted, -1)
      deltas <- deltas[deltas > 1e-9]
      if (length(deltas) > 0)
        resolution <- min(deltas)
    }
    if (is.na(resolution))
      resolution <- 1
  }
  if (!is.null(jitter) && is.function(jitter))
    x <- jitter(x, resolution)
  
  binArea <- 1 / bincount
  p <- seq(0, 1, length.out = bincount + 1)
  q <- qe(x, w, p)
  # Trimming
  if (trim > 0) {
    x_sorted <- sort(x0)
    q_left <- x_sorted[1 + trim]
    q_right <- x_sorted[length(x_sorted) - trim]
    p_left <- min(p[q >= q_left])
    p_right <- max(p[q <= q_right])
    p <- seq(p_left, p_right, length.out = bincount + 1)
    q <- qe(x, w, p)
  }
  left <- head(q, -1)
  right <- tail(q, -1)
  h <- pmax(1 / bincount / (right - left), 0)
  hist <- data.frame(
    left,
    right,
    center = (left + right) / 2,
    height = h,
    water = h,
    isPeak = FALSE,
    isMode = FALSE,
    isLowland = FALSE
  )
  
  # Detect peaks
  peaks <- c()
  if (h[1] > h[2]) {
    peaks <- c(peaks, 1)
    hist[1, ]$isPeak <- TRUE
  }
  for (i in 2:(bincount - 1))
    if (h[i] >= h[i - 1] && h[i] >= h[i + 1]) {
      peaks <- c(peaks, i)
      hist[i, ]$isPeak <- TRUE
    }
  if (h[bincount] > h[bincount - 1]) {
    peaks <- c(peaks, bincount)
    hist[bincount, ]$isPeak <- TRUE
  }
  
  # Process peaks
  peakCount <- sum(hist$isPeak)
  if (peakCount == 0) {
    peak <- bincount %/% 2
    hist[peak,]$isMode <- TRUE
    modes <- list(list(left = min(x), right = max(x), peak = hist[peak,]$center))
  }
  if (peakCount == 1) {
    peak <- which.max(hist$isPeak)
    hist[peak,]$isMode <- TRUE
    modes <- list(list(left = min(x), right = max(x), peak = hist[peak,]$center))
  }
  
  # Main
  if (peakCount > 1) {
    env <- new.env()
    env$modeLocations <- c()
    env$cutPoints <- c()
    env$hist <- hist
    
    trySplit <- function(env, peak0, peak1, peak2) {
      left <- peak1
      right <- peak2
      waterLevel <- min(h[peak1], h[peak2])
      while (left < right && h[left] > waterLevel)
        left <- left + 1
      while (left < right && h[right] > waterLevel)
        right <- right - 1
      for (i in left:right)
        env$hist[i,]$water <- waterLevel
      
      width <- hist[right,]$right - hist[left,]$left
      totalArea <- width * waterLevel
      totalBinCount <- right - left + 1
      totalBinArea <- totalBinCount * binArea
      binProportion <- totalBinArea / totalArea
      if (binProportion < sensitivity) {
        env$modeLocations <- c(env$modeLocations, hist[peak0,]$center)
        env$hist[peak0,]$isMode <- TRUE
        for (i in left:right)
          env$hist[i,]$isLowland <- TRUE
        cutBinIndex <- which.min(h[left:right]) + left - 1
        env$cutPoints <- c(env$cutPoints, hist[cutBinIndex,]$center)
        return(TRUE)
      }
      return(FALSE)
    }
    
    previousPeaks <- c(peaks[1])
    for (i in 2:length(peaks)) {
      currentPeak <- peaks[i]
      while (length(previousPeaks) > 0 && h[last(previousPeaks)] < h[currentPeak]) {
        if (trySplit(env, first(previousPeaks), last(previousPeaks), currentPeak))
          previousPeaks <- c()
        else
          previousPeaks <- head(previousPeaks, -1)
      }
      if (length(previousPeaks) > 0 && h[last(previousPeaks)] > h[currentPeak])
        if (trySplit(env, first(previousPeaks), last(previousPeaks), currentPeak))
          previousPeaks <- c()
      previousPeaks <- c(previousPeaks, currentPeak)
    }
    modeLocations <- env$modeLocations
    cutPoints <- env$cutPoints
    hist <- env$hist
    
    modeLocations <- c(modeLocations, hist[first(previousPeaks),]$center)
    hist[first(previousPeaks),]$isMode <- TRUE
    if (length(modeLocations) == 0)
      modes <- list(list(left = min(x), right = max(x), peak = Q(x, 0.5)))
    if (length(modeLocations) == 1)
      modes <- list(list(left = min(x), right = max(x), peak = modeLocations[1]))
    if (length(modeLocations) > 1) {
      firstMode <- list(left = min(x),
                        right = first(cutPoints),
                        peak = first(modeLocations))
      modes <- list(firstMode)
      if (length(modeLocations) > 2) {
        for (i in 2:(length(modeLocations) - 1)) {
          mode <- list(left = cutPoints[i - 1],
                       right = cutPoints[i],
                       peak = modeLocations[i])
          modes[[length(modes) + 1]] <- mode
        }
      }
      lastMode <- list(left = last(cutPoints),
                       right = max(x),
                       peak = last(modeLocations))
      modes[[length(modes) + 1]] <- lastMode
    }
  }
  
  # Result
  list(
    x = x,
    hist = hist,
    modes = modes,
    modality = length(modes)
  )
}

draw_lowland <- function(x,
                         w = NA,
                         sensitivity = 0.5,
                         bincount = 1000,
                         trim = 1,
                         qe = whdquantile,
                         resolution = NA,
                         jitter = lowland_jitter) {
  l <- lowland(x, w, sensitivity, bincount, trim, qe, resolution, jitter)
  hist <- l$hist
  hist$index <- 1:nrow(hist)
  hist$deepWater <- ifelse(hist$isLowland, hist$water, hist$height)
  hist$shallowWater <- ifelse(!hist$isLowland, hist$water, hist$height)
  
  df <- gather(hist, "type", "x", 1:2)
  df <- df[order(df$index, df$x),]
  df.gw <- df
  df.gw[df.gw$height == df.gw$water,]$height <- 0
  
  polygon.df <- function(x, y1, y2, type) {
    df.p <- data.frame(
      x = c(x, rev(x)),
      y = c(y1, rev(y2)),
      type = type
    )
  }
  levels <- c("Mountain", "Ground Water", "Deep Water", "Shallow Water")
  df.p1 <- polygon.df(df$x, rep(0, nrow(df)), df$height, levels[1])
  df.p2 <- polygon.df(df.gw$x, rep(0, nrow(df)), df.gw$height, levels[2])
  df.p3 <- polygon.df(df$x, df$height, df$deepWater, levels[3])
  df.p4 <- polygon.df(df$x, df$height, df$shallowWater, levels[4])
  df.p <- rbind(df.p1, df.p2, df.p3, df.p4)
  df.p$type <- factor(df.p$type, levels = levels)
  df.beacon <- hist[hist$isPeak,]
  df.beacon$type <- factor(ifelse(df.beacon$isMode, "Mode", "Minor Peak"),
                           levels = c("Mode", "Minor Peak"))
  modeCount <- sum(hist$isMode)
  
  palette <- list(
    mountain = "#E5BF72",
    shallowWater = "#A9DAF2",
    deepWater = "#2EA7E8",
    groundWater = "#D89E2B",
    mode = "#227200",
    minorPeak = "#BF724C"
  )
  ggplot() +
    geom_polygon(data = df.p,
                 mapping = aes(x, y, fill = type),
                 linewidth = 0,
                 alpha = 0.9) +
    geom_point(data = df.beacon,
               mapping = aes(x = center, y = height, col = type),
               shape = 17,
               size = 4) +
    geom_rug(data = data.frame(x), mapping = aes(x), sides = "b") +
    scale_fill_manual(values = c(palette$mountain,
                                 palette$groundWater,
                                 palette$deepWater,
                                 palette$shallowWater)) +
    scale_color_manual(values = c(palette$mode, palette$minorPeak)) +
    theme(legend.text = element_text(size = 7),
          legend.title = element_blank(),
          plot.title = element_text(hjust = 0.5)) +
    ylab("Density") +
    ggtitle(paste0("Lowland Modality: ", modeCount))
}


# Figures ----------------------------------------------------------------------
figure_boundary1 <- function() {
  set.seed(1729)
  x <- rnorm(20)
  draw_lowland(x, trim = 0) +
    ggtitle("Lowland Modality: 2 (Without Trimming)")
}

figure_boundary2 <- function() {
  x <- c(481, 54, 72, 50, 61, 72, 63, 56, 72, 46, 81, 98, 59, 67, 81, 89, 86, 53, 58, 
         92, 51, 60, 58, 56, 70, 69, 65, 68, 452, 63, 55, 62, 56, 60, 93, 81, 47, 35, 
         88, 60, 534, 63, 73, 203, 54, 70, 58, 56, 436, 81, 65, 72, 53, 74, 51, 49, 69, 
         57, 73, 567, 93, 451, 79, 556, 58, 571, 107, 78, 45, 91, 423, 78, 112, 74, 73, 
         60, 56, 58, 502, 501, 54, 96, 72, 65, 98, 68, 49, 60, 65, 110, 58, 56, 65, 67)
  draw_lowland(x, trim = 0) +
    ggtitle("Lowland Modality: 2 (Without Trimming)")
}

figure_trimming1 <- function() {
  set.seed(1729)
  x <- rnorm(20)
  draw_lowland(x) +
    ggtitle("Lowland Modality: 1 (With Trimming)")
}

figure_trimming2 <- function() {
  x <- c(481, 54, 72, 50, 61, 72, 63, 56, 72, 46, 81, 98, 59, 67, 81, 89, 86, 53, 58, 
         92, 51, 60, 58, 56, 70, 69, 65, 68, 452, 63, 55, 62, 56, 60, 93, 81, 47, 35, 
         88, 60, 534, 63, 73, 203, 54, 70, 58, 56, 436, 81, 65, 72, 53, 74, 51, 49, 69, 
         57, 73, 567, 93, 451, 79, 556, 58, 571, 107, 78, 45, 91, 423, 78, 112, 74, 73, 
         60, 56, 58, 502, 501, 54, 96, 72, 65, 98, 68, 49, 60, 65, 110, 58, 56, 65, 67)
  draw_lowland(x) +
    ggtitle("Lowland Modality: 2 (With Trimming)")
}

# Plotting ---------------------------------------------------------------------
regenerate_figures()
