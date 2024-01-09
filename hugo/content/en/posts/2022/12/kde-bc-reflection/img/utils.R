# Libraries --------------------------------------------------------------------

## Init pacman
suppressMessages(if (!require("pacman")) install.packages("pacman"))
suppressMessages(p_unload(all))
library(pacman)

## Plotting
p_load(ggplot2)
p_load(ggdark)
p_load(ggpubr)
p_load(gridExtra)
p_load(latex2exp)

## Essential
p_load(tidyverse)

## Misc
p_load(rtern)
p_load(Hmisc)
p_load(robustbase)
p_load(Rfast)
p_load(knitr)
# p_load(future.apply)

# Preparation ------------------------------------------------------------------

## Clear the environment
rm(list = ls())

## Prepare multithreading environment
# plan(multisession)

# Helpers ----------------------------------------------------------------------

## A color palette adopted for color-blind people based on https://jfly.uni-koeln.de/color/
cbp <- list(
  red = "#D55E00", blue = "#56B4E9", green = "#009E73", orange = "#E69F00",
  navy = "#0072B2", pink = "#CC79A7", yellow = "#F0E442", grey = "#999999"
)
cbp$values <- unname(unlist(cbp))

## A smart ggsave wrapper
ggsave_ <- function(name, plot = last_plot(), basic_theme = theme_bw(), multithemed = T, ext = "svg",
                    dpi = 300, width_px = 1.5 * 1600, height_px = 1.6 * 900) {
  if (is.function(name)) {
    plot <- name
    name <- as.character(match.call()[2])
    if (startsWith(name, "figure_") || startsWith(name, "figure.")) {
      name <- substring(name, nchar("figure_") + 1)
    }
  }

  get_plot <- function() if (is.function(plot)) plot() else plot

  width <- width_px / dpi
  height <- height_px / dpi
  if (multithemed) {
    old_theme <- theme_set(basic_theme)
    ggsave(paste0(name, "-light.", ext), get_plot(), width = width, height = height, dpi = dpi)
    message("SAVED  : ./", paste0(name, "-light.", ext))
    theme_set(dark_mode(basic_theme, verbose = FALSE))
    ggsave(paste0(name, "-dark.", ext), get_plot(), width = width, height = height, dpi = dpi)
    message("SAVED  : ./", paste0(name, "-dark.", ext))
    theme_set(old_theme)
    invert_geom_defaults()
  } else {
    old_theme <- theme_set(basic_theme)
    ggsave(paste0(name, ".", ext), plot, width = width, height = height, dpi = dpi)
    message("SAVED  : ./", paste0(name, ".", ext))
    theme_set(old_theme)
  }
}

regenerate_figures <- function() {
  ## Remove all existing images
  for (file in list.files()) {
    if (endsWith(file, ".png") || endsWith(file, ".svg")) {
      file.remove(file)
    }
  }
  
  ## Draw all the defined figures
  for (func in lsf.str(envir = .GlobalEnv)) {
    if (startsWith(func, "figure_") || startsWith(func, "figure.")) {
      name <- substring(func, nchar("figure_") + 1)
      ggsave_(name, get(func))
    }
  }
}

with_logging <- function(func) {
  function(...) {
    message("START  : ", sys.calls()[[length(sys.calls())]])
    start_time <- Sys.time()
    result <- func(...)
    end_time <- Sys.time()
    elapsed <- end_time - start_time
    if (as.numeric(elapsed, units = "secs") > 1) {
      message("FINISH : ", sys.calls()[[length(sys.calls())]], "(elapsed: ", format(end_time - start_time, digits = 2), ")")
    } else {
      message("FINISH : ", sys.calls()[[length(sys.calls())]])
    }
    result
  }
}

apply_settings <- function(s, overwrite = FALSE) {
  envir <- parent.frame()
  for (i in 1:length(s)) {
    name <- names(s)[i]
    if (!exists(name, envir = envir) || is.null(get(name, envir = envir)) || overwrite) {
      assign(name, s[[i]], envir = envir)
    }
  }
}

multi_estimate <- function(rebuild, filename, ns, process) {
  df <- if (!is.null(filename) && file.exists(filename) && !rebuild) read.csv(filename) else data.frame()
  
  ns_new <- ns[!(ns %in% unique(df$n))]
  if (length(ns_new) == 0) {
    if (!identical(order(df$n), 1:nrow(df))) {
      df <- df[order(df$n), ]
      if (!is.null(filename)) {
        write.csv(df, filename, quote = FALSE, row.names = FALSE)
      }
    }
    return(df)
  }
  
  function_title <- deparse(sys.calls()[[max(1, length(sys.calls()) - 1)]])
  message("START  : ", function_title)
  total_start_time <- Sys.time()
  
  filename_copy <- paste0("copy-", filename)
  for (n in ns_new) {
    set.seed(1729 + n)
    start_time <- Sys.time()
    df_n <- process(n)
    df <- rbind(df, df_n)
    df <- df[order(df$n), ]
    
    if (!is.null(filename)) {
      file.copy(filename, filename_copy, overwrite = TRUE)
      write.csv(df, filename, quote = FALSE, row.names = FALSE)
    }
    
    message(paste0(
      "  ",
      paste(names(df_n), df_n, sep = "=", collapse = "; "),
      " (elapsed: ", format(Sys.time() - start_time, digits = 2), ")"
    ))
  }
  if (file.exists(filename_copy)) {
    file.remove(paste0("copy-", filename))
  }
  
  total_elapsed <- Sys.time() - total_start_time
  if (as.numeric(total_elapsed, units = "secs") > 1) {
    message("FINISH : ", function_title, " (elapsed: ", format(total_elapsed, digits = 2), ")")
  } else {
    message("FINISH : ", function_title)
  }
  
  df
}

extract_columns <- function(df, prefix) {
  drop <- names(df)[!startsWith(names(df), prefix) & grepl(".", names(df), fixed = TRUE)]
  df %>% select(-all_of(drop)) %>% rename_with(function(s) str_replace(s, paste0(prefix, "."), ""))
}