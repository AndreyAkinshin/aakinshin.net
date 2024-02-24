library(shiny)
library(ggplot2)
library(deSolve)
library(plotly)
library(dplyr)
library(rlist)
library(tidyr)

source("core.R")

shinyServer(function(input, output, session) {

  output$plot3D <- renderPlotly({
    req(input$a1)
    req(input$a2)
    req(input$a3)
    req(input$k1)
    req(input$k2)
    req(input$k3)
    req(input$TotalTime)
    req(input$SkipTime)
    req(input$N)
    req(input$Seed)

    context <- list(
      a1 = input$a1,
      a2 = input$a2,
      a3 = input$a3,
      k1 = input$k1,
      k2 = input$k2,
      k3 = input$k3,
      TotalTime = input$TotalTime,
      SkipTime = input$SkipTime,
      N = input$N,
      Seed= input$Seed
    )
    res <- simulate(context)
    traj <- res$traj
    plot_ly(
      traj, x = ~x1, y = ~x2, z = ~x3,
      type = 'scatter3d', mode = 'lines', opacity = 1, color = ~name,
      colors = sample(rainbow(length(unique(traj$name))))) %>%
      layout(showlegend = FALSE, width = 900, height = 600)
  })

  output$htmlOutput <- renderUI({
    context <- reactiveValuesToList(input)
    rnd <- function(x) { if (is.complex(x) & abs(Im(x)) < 1e-9) round(Re(x), 6) else round(x, 6) }
    fmt <- function(x) { if (is.na(x)) "         ?" else formatC(x, digits = 6, width = 10, format = "f") }
    hr <- "-----------------------------------------------------------------<br>"
    text <- with(context, {
      paste0(
        "<pre>",
        "System:<br>",
        "dx1 = L(a1, k1, x3) - k1 * x1<br>",
        "dx2 = L(a2, k2, x1) - k2 * x2<br>",
        "dx3 = L(a3, k3, x2) - k3 * x3<br>",
        "L(a, k, x) = { a * k (for 0≤x≤1)<br>",
        "             { 0     (for 1&lt;x)<br>",
        "<br>",
        "Parameters:<br>",
        "a1 = ", a1, "<br>",
        "a2 = ", a2, "<br>",
        "a3 = ", a3, "<br>",
        "k1 = ", k1, "<br>",
        "k2 = ", k2, "<br>",
        "k3 = ", k3, "<br>",
        "TotalTime = ", TotalTime, "<br>",
        "SkipTime = ", SkipTime, "<br>",
        "N = ", N, "<br>",
        "Seed = ", Seed, "<br>",
        "</pre>"
        )
    })
    HTML(text)
  })

  output$save_state <- downloadHandler(
    filename = function() {
      paste0("data-", Sys.Date(), "-", randomCodeName(), ".yaml")
    },
    content = function(file) {
      data <- list(
        a1 = input$a1,
        a2 = input$a2,
        a3 = input$a3,
        k1 = input$k1,
        k2 = input$k2,
        k3 = input$k3,
        TotalTime = input$TotalTime,
        SkipTime = input$SkipTime,
        N = input$N,
        Seed = input$Seed
      )
      data <- data[names(data) != "restore_state"]
      list.save(data, file)
    }
  )

  loadedData <- reactive({
    list.load(input$restore_state$datapath)
  })
  observe({
    data <- loadedData()
    updateSliderInput(session, "a1", value = data$a1)
    updateSliderInput(session, "a2", value = data$a2)
    updateSliderInput(session, "a3", value = data$a3)
    updateSliderInput(session, "k1", value = data$k1)
    updateSliderInput(session, "k2", value = data$k2)
    updateSliderInput(session, "k3", value = data$k3)
    updateSliderInput(session, "TotalTime", value = data$TotalTime)
    updateSliderInput(session, "SkipTime", value = data$SkipTime)
    updateSliderInput(session, "N", value = data$N)
    updateSliderInput(session, "Seed", value = data$Seed)
  })
})

