#' aster HTMLwidget
#'
#' @param data data frame holding chart data, expects columns id, order, score, weight, color and label
#' @param width chart width
#' @param height chart height
#' @param background_color chart background color, default transparent
#' @param text_offset value between 0 and +inf, values smaller than 1  place text labels inside slices, values larger than 1 place text labels outside slices, default 1
#' @param font_color label font color, default black
#' @param tooltipStyle tooltip style, see http://qtip2.com/options#style for details, defaults to 'qtip-dark qtip-shadow qtip-tipsy',
#' @param inner values smaller than 1 create donut charts (instead of pies), defaults to 0.3
#' @param stroke arc edge color, default grey
#' @param hover_color, slice hover color, default blue
#' @param font_size label text font size, default 12px
#' @param font_size_center font size numeric value in chart center, default 50px
#' @param margin_top chart top margin, default 40
#' @param margin_right chart right margin, default 80
#' @param margin_bottom chart bottom margin, default 40
#' @param margin_left chart left margin, default 80
#'
#' @export
aster <- function(data = data.frame(id     = c("FIS","MAR","AO","NP","CS"),
                                    order  = c(1.1,1.3,2.0,3.0,4.0),
                                    score  = c(59,24,98,60,74),
                                    weight = c(0.5,0.5,1,1,1),
                                    color  = c("#9E0041","#C32F4B","#E1514B","#F47245","#FB9F59"),
                                    label  = c("Fisheries","Mariculture","Artisanal Fishing Opportunities","Natural Products","Carbon Storage")),

                  width = NULL, height = NULL, background_color = "transparent", text_offset = 1, font_color = "black",
                  tooltipStyle = 'qtip-dark qtip-shadow qtip-tipsy',
                  inner = 0.3, stroke = "grey", hover_color = "blue", font_size = "12px", font_size_center = "50px",
                  margin_top =  40, margin_right = 80, margin_bottom = 40, margin_left = 80){

  # forward options using x
  x = list(
    data             = toJSON(data),
    inner            = inner,
    stroke           = stroke,
    hover_color      = hover_color,
    font_size        = font_size,
    font_color       = font_color,
    tooltipStyle     = tooltipStyle,
    font_size_center = font_size_center,
    background_color = background_color,
    text_offset      = text_offset,
    margin_top       = margin_top,
    margin_right     = margin_right,
    margin_left      = margin_left,
    margin_bottom    = margin_bottom
  )

  # create widget
  htmlwidgets::createWidget(
    name    = 'aster',
    x       = x,
    width   = width,
    height  = height,
    package = 'aster'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
asterOutput <- function(outputId, width = '500px', height = '500px'){
  shinyWidgetOutput(outputId, 'aster', width, height, package = 'aster')
}

#' Widget render function for use in Shiny
#'
#' @export
renderAster <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, asterOutput, env, quoted = TRUE)
}
