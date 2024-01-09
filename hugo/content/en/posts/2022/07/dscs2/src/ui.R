library(shiny)
library(plotly)

slider <- function(title, min, max, value = min) {
  sliderInput(title, title, min, max, value, 0.1)
}
sliderA <- function(title, value = 10) slider(title, 0, 20, value)
sliderK <- function(title, value = 1) slider(title, 0, 20, value)

shinyUI(fluidPage(

  titlePanel("Piecewise linear 3D system (LLL)"),

  sidebarLayout(
    sidebarPanel(
      div(style = "overflow-y:scroll; max-height: 700px; position:relative;",
      h2("Parameters"),

      sliderA("a1", 2.5),
      sliderA("a2", 3),
      sliderA("a3", 5),

      sliderK("k1", 1),
      sliderK("k2", 2.5),
      sliderK("k3", 4),

      hr(),

      sliderInput("TotalTime", "TotalTime", 1, 100, 10, 1),
      sliderInput("SkipTime", "SkipTime", 0, 20, 0.2, 0.1),
      sliderInput("N", "N (number of trajectories)", 1, 100, 10, 1),
      sliderInput("Seed", "Randomization seed", 1, 100, 1, 1),

      br(),
      br(),
      downloadButton("save_state", "Save parameters to file"),
      br(),
      br(),
      fileInput("restore_state", "Load parameters from file",
                placeholder = ".yaml file")
    )),

    mainPanel(
      plotlyOutput("plot3D", width = "900px", height = "600px"),
      htmlOutput("htmlOutput")
    )
  )
))
