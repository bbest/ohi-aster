shinyUI(
  fluidPage(

      br(),

      h1("d3.js aster chart output binding example"),

      br(),

      fluidRow(
        column(4 , asterOutput(outputId = "aster1", width = "400px", height = "400px")),
        column(4 , asterOutput(outputId = "aster2", width = "400px", height = "400px")),
        column(4 , asterOutput(outputId = "aster3", width = "400px", height = "400px"))
      ),

      br(), br(), br(),

      fluidRow(
        column(4 , uiOutput("label1")),
        column(4 , uiOutput("label2")),
        column(4 , uiOutput("label3"))
      ),

      br(),

      div( style = "position:relative",
        leafletOutput("map"),
        absolutePanel(top = 10, right = 100, asterOutput(outputId = "aster4", width = "200px", height = "200px"))
      )


  )
)