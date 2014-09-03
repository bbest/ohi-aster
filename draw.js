
var dataset = [
   { width: 20, length: 50, id: 1},
   { width: 20, length: 60, id: 2},
   { width: 20, length: 50, id: 3},
   { width: 20, length: 70, id: 3},
   { width: 20, length: 80, id: 3},
];

var width = 460,
    height = 300,
    radius = Math.min(width, height) / 2;

var innerRadius = 0.2 * radius;

var color = d3.scale.category20();

var pie = d3.layout.pie()
    .value(function(d) { return d.width; });

var arc = d3.svg.arc()
        .innerRadius(innerRadius)
        .outerRadius(function (d) { return (radius - innerRadius) * (d.data.length / 100.0) + innerRadius; });

var outlineArc = d3.svg.arc()
        .innerRadius(innerRadius)
        .outerRadius(radius);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var path = svg.selectAll(".solidArc")
    .data(pie(dataset))
  .enter().append("path")
    .attr("fill", function(d, i) { return color(i); })
    .attr("class", "solidArc")
    .attr("stroke", "gray")
    .attr("d", arc)
    .on("click", function (d) { console.log(d); });

var outerPath = svg.selectAll(".outlineArc")
    .data(pie(dataset))
  .enter().append("path")
    .attr("fill", "none")
    .attr("stroke", "gray")
    .attr("class", "outlineArc")
    .attr("d", outlineArc);
