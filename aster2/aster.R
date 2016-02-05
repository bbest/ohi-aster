asterOutput <- function(outputId, width="100%", height="400px") {

  style <- sprintf("width: %s; height: %s;", validateCssUnit(width), validateCssUnit(height))

  tagList(
    singleton(tags$head(
      tags$script(src="d3.min.js"),
      tags$script(src="d3tip.js"),
      tags$script(src="aster.js"),
      tags$link(rel="stylesheet", type="text/css", href="style.css")
    )),

    div(id=outputId, class="ohiAster", style= style,
        tag("svg", list())
    )
  )
}


renderAster<- function(expr, env = parent.frame(), quoted=FALSE) {

  installExprFunction(expr, "func", env, quoted)

  function() {

    L <- func()

    return(list(data = toJSON(L$data), options = L$options))
  }
}