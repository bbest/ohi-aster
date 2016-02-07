###
### create an HTMLWidget for an aster d3.js chart
###

# libraries
library(htmlwidgets)
library(devtools)

# set working directory
path <- "C:/Users/hsontrop/Desktop/"
setwd(path)

# create package called aster using devtools
devtools::create("aster")

# navigate to package dir
setwd("aster")

# create widget scaffolding
htmlwidgets::scaffoldWidget("aster")

# install the package so we can try it
devtools::install()

###
### we now have an very barebones version of an aster package, which almost does nothing, execpt printing a message
###

# load the library
library("aster")

# call the widget, which just prints a message, here "hello!" to the RSTUDIO Viewer pane
aster("hello!")




