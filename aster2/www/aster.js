//Immediately Invoked Function Expression (IIFE).
(function() {

  // create a generic output binding instance, then overwrite specific methods whose behavior we want to change.
  var binding = new Shiny.OutputBinding();

  binding.find = function(scope) {
    // for the given scope, return the set of elements that belong to this binding.
    return $(scope).find(".ohiAster");
  };

  // The next function will be called every time we receive new output values from the server
  binding.renderValue = function(el, L) {

    var data = L.data;
    var options = L.options;

    // The "el" argument is the div for this particular chart.
    var $el = $(el);

    // The first time we render a value for a particular element, we
    // need to initialize the nvd3 line chart and d3 selection. We'll
    // store these on $el as a data value called "state".
    if (!$el.data("state")) {

      // determine element width
      var width = 0.95 * $el.width();

      // determine element height
      var height = 0.95 * $el.height();

      var margin = {top: 40, right: 80, bottom: 40, left: 80};

      var radius = Math.min(width, height) / 2;

      var innerRadius = options.inner * radius;

      var pie = d3.layout.pie()
      .sort(null)
      .value(function(d) { return d.width; });

      var tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([0, 0])
      .html(function(d) {
        return d.data.label + ": <span style='color:orangered'>" + d.data.score + "</span>";
      });

      var arc = d3.svg.arc()
        .innerRadius(innerRadius)
        .outerRadius(function (d) {
          return (radius - innerRadius) * (d.data.score / 100.0) + innerRadius;
      });

      var outlineArc = d3.svg.arc()
      .innerRadius(innerRadius)
      .outerRadius(radius);

      // grab the chart and set up drawing canvas
      var svg = d3.select(el).select("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + (width / 2 + margin.left) + "," + (height / 2 + margin.top) + ")");

      svg.call(tip);

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
      .attr("stroke", options.stroke) // set stroke
      .attr("d", arc)
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide);

      // dynamically set color on hover
      d3.select(el).selectAll(".solidArc")
      .on("mouseover", function(d) {

        // send hover label info to shiny for given element el
        Shiny.onInputChange("hoverLabel_" + el.id, d.data.label);

        // change to custom fill color to highlight hover event
        d3.select(this).style('fill', options.hover_color);
      })
      .on("mouseout",  function() {

        // return to normal color (based on data bound to chart)
        d3.select(this).style('fill', function(d) { return d.color}); // Re-sets the original fill
      });


      outerGroup
      .append("text")
      .attr("transform", function(d) {
      return "translate(" + centroid(60, width, d.startAngle, d.endAngle) + ")";
      })
      .attr("text-anchor", "middle")
      .style("font-size",options.font_size)
      .text(function(d) { return d.data.label });

      var outerPath = svg.selectAll(".outlineArc")
        .data(pie(data))
        .enter().append("path")
        .attr("fill", "none")
        .attr("stroke", options.stroke) // set stroke
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

      svg.append("svg:text")
      .attr("class", "aster-score")
      .attr("dy", ".35em")
      .attr("text-anchor", "middle") // text-align: right
      .style("font-size",options.font_size_mean)
      .text(Math.round(score));

      function centroid(innerR, outerR, startAngle, endAngle){
        var r = (innerR + outerR) / 2, a = (startAngle + endAngle) / 2 - (Math.PI / 2);
        return [ Math.cos(a) * r, Math.sin(a) * r ];
      }
    }

  };

  // inform Shiny about the new output binding
  Shiny.outputBindings.register(binding, "ohiAsterOutputBinding");

})();