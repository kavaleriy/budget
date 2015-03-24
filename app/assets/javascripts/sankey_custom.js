function get_sankey(rot_file_id, rov_file_id) {

    console.log(rot_file_id, rov_file_id);
    $('#sankey_chart').html('').css("height", "500px");
    $('#sankey_save').css("display", "block");

    var energy = {"nodes" : [
        {"name": "Загальний фонд"},
        {"name": "Спеціальний фонд"},
        {"name": "Інші доходи"},              // for less than 5% amount
        {"name": "Інші видатки"},
    ],
        "links" : []
    };

    d3.json("/sankeys/get_rows/" + rot_file_id + "/" + rov_file_id, function(data) {
        var keys = data["keys_revenue"];
        var d = data["rows_rot"]["2015"]["0"];
        var revenues = 0;
        var genAmount = 0;
        var specAmount = 0;
        var elseAmount_gen = 0;
        var elseAmount_spec = 0;

        for(i in d) {
            revenues += d[i].amount;
        }

        for(i in d) {
            if(d[i].amount*100/revenues >= 5) {        // second parametr - for those codes which has no description
                //console.log(d[i]);
                var key;
                keys[d[i].kkd_ddd] ? key = keys[d[i].kkd_ddd]["description"] : key = d[i].kkd_ddd;
                energy.nodes.push({ "name": key });
                energy.links.push({ "source": key,
                    "target": d[i].fond,
                    "value": d[i].amount,
                });
            } else if(d[i].fond == "Загальний фонд") {
                elseAmount_gen += d[i].amount;
            } else if(d[i].fond == "Спеціальний фонд") {
                elseAmount_spec += d[i].amount;
            }
        }

        energy.links.push({ "source": "Інші доходи",
                "target": "Загальний фонд",
                "value": elseAmount_gen,
            },
            { "source": "Інші доходи",
                "target": "Спеціальний фонд",
                "value": elseAmount_spec,
            });

        keys = data["keys_expense"];
        d = data["rows_rov"]["2015"]["0"];
        expences = 0;
        elseAmount_gen = 0;
        elseAmount_spec = 0;

        for(i in d) {
            expences += d[i].amount;
        }

        for(i in d) {
            if(d[i].amount*100/expences >= 5) {
                var k = parseInt(d[i].ktfk)
                var key = keys[k]["description"];
                energy.nodes.push({ "name": key });
                energy.links.push({ "source": d[i].fond,
                    "target": key,
                    "value": d[i].amount,
                });
            } else if(d[i].fond == "Загальний фонд") {
                elseAmount_gen += d[i].amount;
            } else if(d[i].fond == "Спеціальний фонд") {
                elseAmount_spec += d[i].amount;
            }
        }

        energy.links.push({ "source": "Загальний фонд",
                "target": "Інші видатки",
                "value": elseAmount_gen,
            },
            { "source": "Спеціальний фонд",
                "target": "Інші видатки",
                "value": elseAmount_spec,
            });

        create_sankey(energy, revenues, expences);
    });
}

function create_sankey(energy, revenues, expences) {
    // return only the distinct / unique nodes
    energy.nodes = d3.keys(d3.nest()
        .key(function (d) { return d.name; })
        .map(energy.nodes));

    // loop through each link replacing the text with its index from node
    energy.links.forEach(function (d, i) {
        energy.links[i].source = energy.nodes.indexOf(energy.links[i].source);
        energy.links[i].target = energy.nodes.indexOf(energy.links[i].target);
    });

    //now loop through each nodes to make nodes an array of objects
    // rather than an array of strings
    energy.nodes.forEach(function (d, i) {
        energy.nodes[i] = { "name": d };
    });

    var margin = {top: 80, right: 1, bottom: 30, left: 1},
        width = 1200 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var formatNumber = d3.format(",.0f"),
        format = function(d) { return formatNumber(d) + " TWh"; },
        color = d3.scale.category20();

    d3.select("#sankey_chart").selectAll('*').remove();
    var svg = d3.select("#sankey_chart").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var sankey = d3.sankey()
        .nodeWidth(15)
        .nodePadding(10)
        .size([width, height]);

    var path = sankey.link();

    sankey
        .nodes(energy.nodes)
        .links(energy.links)
        .layout(32);

    var link = svg.append("g").selectAll(".link")
        .data(energy.links)
        .enter().append("path")
        .attr("class", "link")
        .attr("d", path)
        .style("stroke-width", function(d) { return Math.max(1, d.dy); })
        .sort(function(a, b) { return b.dy - a.dy; });

    link.append("title")
        .text(function(d) { return d.source.name + " → " + d.target.name + "\n" + format(d.value); });

    var node = svg.append("g").selectAll(".node")
        .data(energy.nodes)
        .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
        .call(d3.behavior.drag()
            .origin(function(d) { return d; })
            .on("dragstart", function() { this.parentNode.appendChild(this); })
            .on("drag", dragmove));

    node.append("rect")
        .attr("height", function(d) { return d.dy; })
        .attr("width", function(d) {
            if(d.name == "Загальний фонд" || d.name == "Спеціальний фонд") return 150;
            return sankey.nodeWidth();
        } )
        .style("fill", function(d) { return d.color = color(d.name.replace(/ .*/, "")); })
        .style("stroke", function(d) { return d3.rgb(d.color).darker(2); })
        .append("title")
        .text(function(d) { return d.name + "\n" + format(d.value); });

    node.append("text")
        .attr("x", -6)
        .attr("y", function(d) { return d.dy / 2; })
        .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .attr("transform", null)
        .text(function(d) { return d.name; })
        .filter(function(d) { return d.x < width / 2; })
        .attr("x", 6 + sankey.nodeWidth())
        .attr("text-anchor", "start");

    function dragmove(d) {
        d3.select(this).attr("transform", "translate(" + d.x + "," + (d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))) + ")");
        sankey.relayout();
        link.attr("d", path);
    }

    // central rectangle for General and Special funds
    svg.append("rect")
        .attr("x", width/2 - 75)
        .attr("y", -margin.top + 1)
        .style("fill", "none")
        .style("stroke", "#082757")
        .style("stroke-width", 2)
        .attr("width", 166)
        .attr("height", height + margin.top + margin.bottom - 2);

    svg.append("text")
        .attr("x", width/2 + 10)
        .attr("y", -margin.top + 25)
        .attr("text-anchor", "middle")
        .style("fill", "#082757")
        .style("font-size", "0.7em")
        .style("font-weight", "bold")
        .text("Бюджет міста за 2015 р.");

    // rectangles for revenues and expences total amount
    for(var i = 0; i < 3; i++) {
        svg.append("rect")
            .attr("x", function(){
                if(i == 0) return width/4;
                if(i == 1) return width/2 - 68;
                return width/2 + 118;
            })
            .attr("y", function(){
                if(i == 1) return -margin.top/2 + 1;
                return -margin.top + 1;
            })
            .attr("rx", 10)
            .attr("ry", 10)
            .style("fill", function(){
                if(i == 1) {
                    if(revenues > expences) return "blue";
                    if(revenues < expences) return "red";
                    if(revenues == expences) return "gray";
                }
                return "none";
            })
            .style("stroke", "#082757")
            .style("stroke-width", 2)
            .attr("width", function(){
                if(i == 1) return width/8;
                return width/6;
            })
            .attr("height", function(){
                if(i == 1) return margin.top/2 - 10;
                return margin.top/2;
            });

        svg.append("text")
            .attr("x", function(){
                if(i == 0) return width/3;
                if(i == 1) return width/2 + 10;
                return 2*width/3 + 20;
            })
            .attr("y", function(){
                if(i == 1) return -margin.top/4;
                return -margin.top + 25;
            })
            .attr("text-anchor", "middle")
            .style("fill", function(){if(i == 1) return "white"; return "#082757";})
            .style("font-size", "1.0em")
            //.style("font-weight", "bold")
            .text(function(){if(i == 0) return "Доходи - " + (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + ". грн.";
                if(i == 1) {
                    if(revenues > expences) return "Профіцит";
                    if(revenues < expences) return "Дефіцит";
                    if(revenues == expences) return "Баланс";
                }
                return "Видатки - " + (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + ". грн.";});
    }
}