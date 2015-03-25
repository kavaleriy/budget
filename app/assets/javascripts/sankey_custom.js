function get_sankey(data, year) {

    $('#sankey_chart').html('').css("height", "500px");
    $('#sankey_save').css("display", "block");

    var energy = {"nodes" : [
        {"name": "Загальний фонд"},
        {"name": "Спеціальний фонд"},
        {"name": "Інші доходи"},              // for less than 5% amount
        {"name": "Інші видатки"},
    ],
        "links" : [],
        "amounts": []
    };

    var keys = data["keys_revenue"];
    var amounts = [];

    // gather amounts for previous year revenues
    var d = data["rows_rot"][year-1];

    if(d){
        d = d["0"];
        for(i in d) {
            var key;
            if(keys[d[i].kkd_ddd] && keys[d[i].kkd_ddd]["title"]) {
                key = keys[d[i].kkd_ddd]["title"];
            } else {
                key = d[i].kkd_ddd;
            }
            //console.log(key);
            amounts[key] = d[i].amount;
        }
    }

    // gather data for revenues side
    d = data["rows_rot"][year]["0"];
    var revenues = sum_amount(d);
    var elseAmount_gen = 0;
    var elseAmount_spec = 0;

    for(i in d) {
        //console.log(d[i]);
        var fond;
        switch (d[i].fond) {
            case "1": fond = "Загальний фонд";
                break;
            case "2": fond = "Власні надходження";
                break;
            case "7": fond = "Спеціальний фонд";
                break;
            default:fond = d[i].fond;
                break;
        }
        if(d[i].amount*100/revenues >= 5) {
            var key;
            if(keys[d[i].kkd_ddd] && keys[d[i].kkd_ddd]["title"]) {
                key = keys[d[i].kkd_ddd]["title"];
            } else {
                key = d[i].kkd_ddd;
            }
            energy.nodes.push({ "name": key });
            energy.links.push({ "source": key,
                                "target": fond,
                                "value": d[i].amount
                              });
            if(amounts[key]){
                energy.amounts[key] = {
                    "prev_value": amounts[key]
                }
            }
        } else if(fond == "Загальний фонд") {
            elseAmount_gen += d[i].amount;
        } else if(fond == "Спеціальний фонд") {
            elseAmount_spec += d[i].amount;
        }
    }

    energy.links.push({ "source": "Інші доходи",
            "target": "Загальний фонд",
            "value": elseAmount_gen
        },
        { "source": "Інші доходи",
            "target": "Спеціальний фонд",
            "value": elseAmount_spec
        });

    keys = data["keys_expense"];
    var d = data["rows_rov"][year-1];
    if(d){
        d = d["0"];
        for(i in d) {
            var key;
            var k = parseInt(d[i].ktfk);
            if(keys[k] && keys[k]["title"]) {
                key = keys[k]["title"];
            } else {
                key = d[i].ktfk;
            }
            amounts[key] = d[i].amount;
        }
    }
    d = data["rows_rov"][year]["0"];
    var expences = sum_amount(d);
    elseAmount_gen = 0;
    elseAmount_spec = 0;

    for(i in d) {
        //console.log(d[i]);
        var fond;
        switch (d[i].fond) {
            case "1": fond = "Загальний фонд";
                break;
            case "2": fond = "Власні надходження";
                break;
            case "7": fond = "Спеціальний фонд";
                break;
            default:fond = d[i].fond;
                break;
        }
        if(d[i].amount*100/expences >= 5) {
            var key;
            var k = parseInt(d[i].ktfk);
            if(keys[k] && keys[k]["title"]) {
                key = keys[k]["title"];
            } else {
                key = d[i].ktfk;
            }
            energy.nodes.push({ "name": key });
            energy.links.push({ "source": fond,
                                "target": key,
                                "value": d[i].amount
                              });
            if(amounts[key]){
                energy.amounts[key] = {
                    "prev_value": amounts[key]
                }
            }
        } else if(fond == "Загальний фонд") {
            elseAmount_gen += d[i].amount;
        } else if(fond == "Спеціальний фонд") {
            elseAmount_spec += d[i].amount;
        }
    }

    energy.links.push({ "source": "Загальний фонд",
            "target": "Інші видатки",
            "value": elseAmount_gen
        },
        { "source": "Спеціальний фонд",
            "target": "Інші видатки",
            "value": elseAmount_spec
        });

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

    var margin = {top: 80, right: 50, bottom: 30, left: 50},
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

    node.append("rect")
        .attr("x", function(d) {
            if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left;
            return 30;})
        //.attr("y", function(d) { return d.dy; })
        .style("fill", "#F0F0F0")
        .style("stroke", "none")
        .attr("width", 40)
        .attr("height", function(d) { if(d.name == "Загальний фонд" || d.name == "Спеціальний фонд") return 0;
                                      return d.dy; })
    node.append("text")
        .text(function(d){
                if(d.name == "Загальний фонд" || d.name == "Спеціальний фонд") return "";
                if(energy.amounts[d.name]) {
                    return (100 - energy.amounts[d.name].prev_value*100/d.value).toFixed(2) + "%";
                }
                return "";
              })
        .attr("text-anchor", "start")
        .attr("dx", function(d) {
            if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -50;
            return 30;})
        .attr("dy", "1.0em")
        .style("font-size", "0.7em");

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
        .attr("x", width/2 - 70)
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
        .text("Бюджет міста за " + year + " р.");

    // rectangles for status bar (total amounts)
    for(var i = 0; i < 3; i++) {
        svg.append("rect")
            .attr("x", function(){
                if(i == 0) return width/4;
                if(i == 1) return width/2 - 58;
                return width/2 + 108;
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
                return 2*width/3 + 15;
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

    // add general info about years compare (placed left to status bar)
    for(var j = 0; j < 2; j++) {
        svg.append("rect")
            .attr("x", function(){
                if(j == 0) return -margin.left;
                return width - width/8 + margin.right;
            })
            .attr("y", -margin.top + 1 )
            .style("fill", "#F0F0F0")
            .style("stroke", "none")
            .attr("width", width/8)
            .attr("height", margin.top - 10);

        var text = svg.append("text")
            .attr("x", function(){if(j == 0) return -margin.left + 10; return width - width/8 + margin.right + 10})
            .attr("y", -margin.top + 25)
            .attr("text-anchor", "start")
            //.style("fill", function(){if(i == 1) return "white"; return "#082757";})
            .style("font-size", "0.8em")
        //.style("font-weight", "bold");

        text.append('tspan')
            .text(function() {
                if(j == 0) return (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + ".грн. - " + year + " р. ";
                return (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + ".грн. - " + year + " р. ";
            });

        d = data["rows_rot"][year-1];
        if(d && j == 0) { // if previous year rot exists
            var prev_revenues = sum_amount(d["0"]);
            text.append('tspan')
                .text((prev_revenues/window.aHelper.k(prev_revenues)).toFixed(2) + " " + window.aHelper.short_unit(prev_revenues) + ".грн. - " + (year-1) + " р.")
                .attr("dy", "1.1em")
                .attr("x", -margin.left + 10);
            text.append('tspan')
                .text(function() {
                    if(revenues > prev_revenues) {
                        return (100 - prev_revenues*100/revenues).toFixed(2) + "% росту"
                    }
                    if(revenues > prev_revenues) {
                        return (prev_revenues*100/revenues - 100).toFixed(2) + "% падіння"
                    }
                    return "не змінилось"
                })
                .attr("dy", "1.1em")
                .attr("x", -margin.left + 10);
        } else if(data["rows_rov"][year-1] && j == 1){
            var prev_expences = sum_amount(data["rows_rov"][year-1]["0"]);
            text.append('tspan')
                .text((prev_expences/window.aHelper.k(prev_expences)).toFixed(2) + " " + window.aHelper.short_unit(prev_expences) + ".грн. - " + (year-1) + " р.")
                .attr("dy", "1.1em")
                .attr("x", width - width/8 + 10 + margin.right);
            text.append('tspan')
                .text(function() {
                    if(expences > prev_expences) {
                        return (100 - prev_expences*100/expences).toFixed(2) + "% росту"
                    }
                    if(expences > prev_expences) {
                        return (prev_expences*100/expences - 100).toFixed(2) + "% падіння"
                    }
                    return "не змінилось"
                })
                .attr("dy", "1.1em")
                .attr("x", width - width/8 + 10 + margin.right);
        }
    }


    function sum_amount(data) {
        var tmp = 0;
        for(i in data) {
            tmp += data[i].amount;
        }
        return tmp;
    }
}

