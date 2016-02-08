shinyServer(function(input, output) {

  # toy data
  ToyData <- function(data){
    data$order  <- runif(nrow(data),1,10)
    data$score  <- runif(nrow(data),20,100)
    data$weight <- runif(nrow(data),0.1,0.5)
    data
  }

  # render aster charts
  output$aster1 <- renderAster({

    options <- list(inner = 0.5, stroke = "red", hover_color = "orangered", font_size = "12px", font_size_mean = "50px")

    list(data = ToyData(data), options = options)
  })

  output$aster2 <- renderAster({

    options <- list(inner = 0.3, stroke = "grey", hover_color = "blue", font_size = "12px", font_size_mean = "50px")

    list(data = ToyData(data), options = options)
  })

  output$aster3 <- renderAster({

    options <- list(inner = 0.8, stroke = "blue", hover_color = "green", font_size = "12px", font_size_mean = "50px")

    list(data = ToyData(data), options = options)
  })

  # small astra chart
  output$aster4 <- renderAster({

    options <- list(inner = 0.4, stroke = "black", hover_color = "pink", font_size = "8px", font_size_mean = "20px")

    list(data = ToyData(data), options = options)
  })

  # hover label information passed from the client to shiny
  output$label1 <- renderUI({
    h1(input$hoverLabel_aster1, style = "text-align:center")
  })

  output$label2 <- renderUI({
    h1(input$hoverLabel_aster2, style = "text-align:center")
  })

  output$label3 <- renderUI({
    h1(input$hoverLabel_aster3, style = "text-align:center")
  })

  # leaflet
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite", options = providerTileOptions(noWrap = TRUE)) %>%
      addMarkers(data = cbind(rnorm(40) * 2 + 13, rnorm(40) + 48))
  })


})
