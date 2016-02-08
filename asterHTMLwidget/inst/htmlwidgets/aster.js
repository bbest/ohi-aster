HTMLWidgets.widget({

  name: 'aster',

  type: 'output',

  initialize: function(el, width, height) {

    // return the width and height to the renderValue function
    return {width: width, height: height};

  },

  renderValue: function(el, x, instance) {

      // el: the div element created by the widget
      // x: holds all the options passed in the widget
      // instance: object that is passed each time we call the widget
      // initial values in instance come from the initialize function in the code block above

      // set the chart dimensions equal to the return value of the initialize function
      var height = instance.height;
      var width  = instance.width;

      // remove previous graph (if it exists i.e. when we after constuction pass new data to the render function in a shiny app
      d3.select(el).select("svg").remove();

      // main data
      var data   = x.data;

      // for margin convention and meaning see: https://bl.ocks.org/mbostock/3019563
      var margin = {top: x.margin_top, right: x.margin_right, bottom: x.margin_bottom, left: x.margin_left};

      // pie dimensions
      var size   = Math.min(width, height);
      var radius = size / 2;
      var innerRadius = x.inner * radius;

      // pie layout function
      var pie = d3.layout.pie()
      .sort(null)
      .value(function(d) { return d.width; });

      // arc function
      var arc = d3.svg.arc()
        .innerRadius(innerRadius)
        .outerRadius(function (d) {
          return (radius - innerRadius) * (d.data.score / 100.0) + innerRadius;
      });

      // outlineArc
      var outlineArc = d3.svg.arc()
      .innerRadius(innerRadius)
      .outerRadius(radius);

      // grab the chart container div el via d3, append an svg tag so d3.js can do its thing and
      // set the dimensions of the svg, finally, append a g tag so we can center the contents in the svg via a transform
      var svg = d3.select(el).append("svg") // note here we
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .style("background",x.background_color)
      .append("g")
      .attr("transform", "translate(" + (width / 2 + margin.left) + "," + (height / 2 + margin.top) + ")");

      // make sure numeric entries are of correct type (+)
      data.forEach(function(d) {
        d.id     =  d.id;
        d.order  = +d.order;
        d.color  =  d.color;
        d.weight = +d.weight;
        d.score  = +d.score;
        d.width  = +d.weight;
        d.label  =  d.label;
      });

      var outerGroup = svg.selectAll(".solidArc")
      .data(pie(data))
      .enter()
      .append("g");

      outerGroup
      .append("path")
      .attr("fill", function(d) { return d.data.color; })
      .attr("class", "solidArc")
      .attr("stroke", x.stroke) // set stroke
      .attr("d", arc)
      .each(function(d){ this._current = d; }); //save each angle to the _current property of the current element

      outerGroup
      .append("text")
      .attr("transform", function(d) {
      return "translate(" + centroid(60, size, d.startAngle, d.endAngle) + ")";
      })
      .attr("text-anchor", "middle")
      .style("font-size",x.font_size) // change the font_size based on htmlwidget options
      .style("fill",x.font_color) // change the font_color based on htmlwidget options
      .text(function(d) { return d.data.label });

      var outerPath = svg.selectAll(".outlineArc")
        .data(pie(data))
        .enter().append("path")
        .attr("fill", "none")
        .attr("stroke", x.stroke) // change the stroke based on htmlwidget options
        .attr("class", "outlineArc")
        .attr("d", outlineArc);

      // calculate the weighted mean score
      var score =
      data.reduce(function(a, b) {
        return a + (b.score * b.weight);
        }, 0) /
      data.reduce(function(a, b) {
      return a + b.weight;
      }, 0);

      // center text
      svg.append("svg:text")
      .attr("class", "aster-score")
      .attr("dy", ".35em")
      .attr("text-anchor", "middle") // text-align: right
      .style("font-size",x.font_size_center) // change the font_size_center based on htmlwidget options
      .text(Math.round(score));

      function centroid(innerR, outerR, startAngle, endAngle){
        var r = x.text_offset * (innerR + outerR) / 2, a = (startAngle + endAngle) / 2 - (Math.PI / 2);
        return [ Math.cos(a) * r, Math.sin(a) * r ];
      }

      // attach qtip2 tooltip, see http://qtip2.com/ , see here for options: http://qtip2.com/demos
      $('.solidArc').qtip({ // grab elements to apply the tooltip to

        // position of tooltip, note we use the __data__ property as the tooltip
        // is based on jQuery, which cannot direcly read the d3.js d property,
        // note that we use an standard html table to layout the tooltip text in rows and columns
        content: {
         text: function(event, api) {

           // get data bound in d3.js via jQuery
           var dd =  $(this).prop("__data__").data;

           // tooltip text
           var tooltipText = '<table border = 1>' +
              '<tr><td>id:</td><td>' + dd.id  + '</td></tr>' +
              '<tr><td>score:</td><td>' + dd.score  + '</td></tr>' +
              '<tr><td>weight:</td><td>' + dd.weight  + '</td></tr>' +
              '<tr><td>label:</td><td>' + dd.label  + '</td></tr>' +
            '</table>';

           return tooltipText;

         }
        },

        // position of tooltip
        position: {
          my: 'top center', // position where tooltip 'pointer' appears
          target: 'mouse', // follow the mouse
          adjust: {y: 20} //  offset the tooltip by 20px (lower in vertical direction) from the current mouse position
        },

        // tooltip style
        style: {
            classes: x.tooltipStyle // tooltip class is passed by the widget via its options
        }
      });


      // dynamically set color on hover
      d3.select(el).selectAll(".solidArc")
      .on("mouseover", function(d) {
        // change to custom fill color to highlight hover event
        d3.select(this).style('fill', x.hover_color);

        // send hoverInfo to shiny
        if(HTMLWidgets.shinyMode){
          Shiny.onInputChange(el.id + "_hoverInfo", d.data);
        }

      })
      .on("mouseout",  function() {

        // return to normal color (based on data bound to chart)
        d3.select(this).style('fill', function(d) { return d.color}); // Re-sets the original fill
      })
      .on("click", function(d) {
        // send clickInfo to shiny
        if(HTMLWidgets.shinyMode){
          Shiny.onInputChange(el.id + "_clickInfo", d.data);
        }

        // return to original value after clicking
        d3.select(this)
         .transition()
         .duration(750)
         .style('fill', function(d) { return d.color});
      });

  },

  resize: function(el, width, height, instance) {

  }

});
