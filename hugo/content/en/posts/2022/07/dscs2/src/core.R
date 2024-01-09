library(deSolve)

simulate <- function(context) {
  with(context, {
    L <- function(a, k, x) ifelse(x < 1, a * k, 0)

    model <- function(t, state, parms) {
      x1 <- as.numeric(state[1])
      x2 <- as.numeric(state[2])
      x3 <- as.numeric(state[3])
      list(c(
        dx1 = L(a1, k1, x3) - k1 * x1,
        dx2 = L(a2, k2, x1) - k2 * x2,
        dx3 = L(a3, k3, x2) - k3 * x3
      ))
    }

    times.step <- 0.01
    times.skip <- min(TotalTime, SkipTime)
    times <- seq(0, TotalTime, by = 0.01)

    simulate <- function(index) {
      get.start <- function(a) runif(1, 0.5, (2 + a) / 3)
      start <- c(x1 = get.start(a1), x2 = get.start(a2), x3 = get.start(a2))
      traj <- as.data.frame(lsoda(start, times, func = model, parms = 0))
      traj$name <- paste0("t", index)
      traj <- traj[round(times.skip / times.step):nrow(traj),]
      traj
    }
    set.seed(Seed)
    traj <- do.call("rbind", lapply(1:N, function(i) simulate(i)))

    list(
      context = context,
      model = model,
      traj = traj
    )
  })
}

randomCodeName <- function() {
  consonants <- c("b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n",
                  "p", "q", "r", "s", "t", "v", "w", "x", "y", "z")
  vowels <- c("a", "e", "i", "o", "u")
  paste0(sample(consonants, 1), sample(vowels, 1),
         sample(consonants, 1), sample(vowels, 1),
         sample(consonants, 1))
}
