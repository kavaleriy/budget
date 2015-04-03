function get_sankey(data, year) {

    $('#sankey_chart').html('').css("height", "500px");
    $('#sankey_save').css("display", "block");

    var energy = {"nodes" : [],
                  "links" : [],
                  "amounts": [],
                  "fonds": []
                 };

    var amounts = [];

    // gather amounts for previous year
    function gather_previous_amounts(d) {
        for(i in d) {     // level of fonds
            for(j in d[i]) {     // level of keys in fonds
                var key = d[i][j].title;
                amounts[key] ? amounts[key] += d[i][j].amount : amounts[key] = d[i][j].amount;  // total amount for one key through all fonds
            }
        }
    }
    if(data["rows_rot"][year-1]){
        gather_previous_amounts(data["rows_rot"][year-1]["0"]);
    }
    if(data["rows_rov"][year-1]){
        gather_previous_amounts(data["rows_rov"][year-1]["0"]);
    }

    // gather data for revenues side
    var revenues = 0;
    var elseAmounts = [];

    if(data["rows_rot"][year]) {
        var d = data["rows_rot"][year]["0"];
        revenues = data["rows_rot"][year]["totals"]["0"];
        var keys = [];
        for(i in d) {
            var fond = get_fond(i);
            for(j in d[i]) {
                if(d[i][j].amount*100/revenues >= 5) {
                    var key = d[i][j].title || j;
                    if(!keys[key]) {
                        energy.nodes.push({ "name": key });
                        keys[key] = key;
                    }
                    energy.links.push({ "source": key,
                                        "target": fond,
                                        "value": d[i][j].amount
                                      });
                    if(amounts[key] && !energy.amounts[key]){
                        energy.amounts[key] = amounts[key];
                    }
                } else {
                    elseAmounts[fond] ? elseAmounts[fond] += d[i][j].amount : elseAmounts[fond] = d[i][j].amount;
                }
            }
        }
    }

    if(Object.keys(elseAmounts).length != 0) {
        energy.nodes.push({"name": "Агреговані доходи"});
        for(var key in elseAmounts) {
            energy.links.push({ "source": "Агреговані доходи",
                                "target": key,
                                "value": elseAmounts[key]
                             });
        }
    }

    // gather data for expences side
    var expences = 0;
    elseAmounts = [];

    if(data["rows_rov"][year]) {
        var d = data["rows_rov"][year]["0"];
        expences = data["rows_rov"][year]["totals"]["0"];
        var keys = [];
        for(i in d) {
            var fond = get_fond(i);
            for(j in d[i]) {
                if(d[i][j].amount*100/expences >= 5) {
                    var key = d[i][j].title || j;
                    if(!keys[key]) {
                        energy.nodes.push({ "name": key });
                        keys[key] = key;
                    }
                    energy.links.push({ "source": fond,
                                        "target": key,
                                        "value": d[i][j].amount
                                     });
                    if(amounts[key] && !energy.amounts[key]){
                        energy.amounts[key] = amounts[key];
                    }
                } else {
                    elseAmounts[fond] ? elseAmounts[fond] += d[i][j].amount : elseAmounts[fond] = d[i][j].amount;
                }
            }
        }
    }

    if(Object.keys(elseAmounts).length != 0) {
        energy.nodes.push({"name": "Агреговані видатки"});
        for(var key in elseAmounts) {
            energy.links.push({ "source": key,
                "target": "Агреговані видатки",
                "value": elseAmounts[key]
            });
        }
    }

    for(var key in energy.fonds) {
        energy.nodes.push({"name": energy.fonds[key]});
    }

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

    var side_rect_width = 60;
    var margin = {top: 80, right: side_rect_width + 10, bottom: 30, left: side_rect_width + 10},
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
        .fonds(energy.fonds)
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
            if(energy.fonds[d.name]) return 150;
            return sankey.nodeWidth();
        } )
        .style("fill", function(d) { return d.color = color(d.name.replace(/ .*/, "")); })
        .style("stroke", function(d) { return d3.rgb(d.color).darker(2); })
        .append("title")
        .text(function(d) { return d.name + "\n" + format(d.value); });

    // side rectangles
    node.append("rect")
        .attr("x", function(d) {
            if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left;
            return side_rect_width/2 - 5;})
        .style("fill", "#F0F0F0")
        .style("stroke", "none")
        .attr("width", side_rect_width)
        .attr("height", function(d) { if(energy.fonds[d.name]) return 0;
                                      return d.dy; });
    // info for side rectangles
    var k_rev = window.aHelper.k(5*revenues/100);
    var k_exp = window.aHelper.k(5*expences/100);
    var side_text = node.append("text")
                        .text(function(d){
                                if(!energy.fonds[d.name]) {
                                    if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return (d.value/k_rev).toFixed(2);
                                    if(d.sourceLinks.length == 0 && d.targetLinks.length != 0) return (d.value/k_exp).toFixed(2);
                                }
                                return "";
                              })
                        .attr("text-anchor", "middle")
                        .attr("dx", function(d) {
                                    if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left/2 - 5;
                                    return side_rect_width - 2;
                              })
                        .attr("dy", function(d) { return d.dy/2; })
                        .style("font-size", "0.7em")
                        .style("font-weight", "bold");

    side_text.append('tspan')
                .text(function(d) {
                    if(energy.amounts[d.name]) {
                        if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return (energy.amounts[d.name]/k_rev).toFixed(2);
                        if(d.sourceLinks.length == 0 && d.targetLinks.length != 0) return (energy.amounts[d.name]/k_exp).toFixed(2);
                    }
                    return "";
                })
                .attr("dy", "1.1em")
                .attr("x", function(d) {
                    if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left/2 - 5;
                    return side_rect_width - 2;})
                .style("font-weight", "normal")
                .attr("fill", "darkslategray");

    side_text.append('tspan')
                .text(function(d) {
                            if(energy.amounts[d.name]) {
                                var x = 0;
                                energy.amounts[d.name] < d.value ? x = 100 - energy.amounts[d.name]*100/d.value : x = d.value*100/energy.amounts[d.name] - 100;
                                return x.toFixed(2) + " %";
                            }
                            return "";
                      })
                .attr("dy", "1.1em")
                .attr("x", function(d) {
                            if(d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left/2 - 5;
                            return side_rect_width - 2;})
                .style("font-weight", "normal")
                .attr("fill", function(d) { return  energy.amounts[d.name] <= d.value ? "green" : "red"});

    append_status_frame(node);

    node.append("text")
        .attr("x", -6)
        .attr("y", function(d) { return d.dy / 2; })
        .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .attr("transform", null)
        .text(function(d) { return d.name; })
        .filter(function(d) { return d.x < width / 2; })
        .attr("x", function(d) { if(energy.fonds[d.name]) return 75;
                                 return 6 + sankey.nodeWidth(); })
        .attr("text-anchor", function(d) { if(energy.fonds[d.name]) return "middle";
                                           return "start"; });

    function dragmove(d) {
        d3.select(this).attr("transform", "translate(" + d.x + "," + (d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))) + ")");
        sankey.relayout();
        link.attr("d", path);
    }

    // central rectangle for General and Special funds
    svg.append("rect")
        .attr("x", width/2 - 68)
        .attr("y", -margin.top + 1)
        .style("fill", "none")
        .style("stroke", "#082757")
        .style("stroke-width", 2)
        .attr("width", 166)
        .attr("height", height + margin.top + margin.bottom - 2);

    svg.append("text")
        .attr("x", width/2 + 14)
        .attr("y", -margin.top + 25)
        .attr("text-anchor", "middle")
        .style("fill", "#082757")
        .style("font-size", "0.7em")
        .style("font-weight", "bold")
        .text("Бюджет міста за " + year + " р.");

    // rectangles for status bar (total amounts)
    for(var i = 0; i < 3; i++) {
        var status_bar = svg.append("g").attr("transform", "translate(0,0)");
        status_bar.append("rect")
            .attr("x", function(){
                if(i == 0) return width/4;
                if(i == 1) return width/2 - 61;
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
                if(i == 1) return width/8 + 20;
                return width/6;
            })
            .attr("height", function(){
                if(i == 1) return margin.top/2 - 10;
                return margin.top/2;
            });

        status_bar.append("text")
            .attr("x", function(){
                if(i == 0) return width/3;
                if(i == 1) return width/2 + 15;
                return 2*width/3 + 30;
            })
            .attr("y", function(){
                if(i == 1) return -margin.top/4;
                return -margin.top + 25;
            })
            .attr("text-anchor", "middle")
            .style("fill", function(){if(i == 1) return "white"; return "#082757";})
            .style("font-size", "0.7em")
            .style("font-weight", "bold")
            .text(function(){if(i == 0) return "Доходи - " + (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + " грн.";
                if(i == 1) {
                    var diff = (Math.abs(revenues - expences)/window.aHelper.k(Math.abs(revenues - expences))).toFixed(2) + " " + window.aHelper.short_unit(Math.abs(revenues - expences)) + " грн."
                    if(revenues > expences) return "Профіцит - " + diff;
                    if(revenues < expences) return "Дефіцит - " + diff;
                    if(revenues == expences) return "Баланс";
                }
                return "Видатки - " + (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + " грн.";});
    }

    // add general info about years compare (placed left to status bar)
    var short_unit_rev = window.aHelper.short_unit(5*revenues/100);
    var short_unit_exp = window.aHelper.short_unit(5*expences/100);
    var prev_revenues = 0;
    var prev_expences = 0;
    for(var j = 0; j < 2; j++) {
        var side_bars = svg.append("g").attr("transform", "translate(0,0)");
        side_bars.append("rect")
            .attr("x", function(){
                if(j == 0) return -margin.left;
                return width - width/8 - 12 + margin.right;
            })
            .attr("y", -margin.top + 1 )
            .style("fill", "#F0F0F0")
            .style("stroke", "none")
            .attr("width", width/8 + 10)
            .attr("height", margin.top - 20);

        var text = side_bars.append("text")
            .attr("x", function(){if(j == 0) return -margin.left + 5; return width - width/8 - 7 + margin.right})
            .attr("y", -margin.top + 25)
            .attr("text-anchor", "start")
            .style("font-size", "0.7em")
            .style("font-weight", "bold");

        text.append('tspan')
            .text(function() {
                if(j == 0) return (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + " грн. - " + year + " р. ";
                return (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + " грн. - " + year + " р. ";
            });

        d = data["rows_rot"][year-1];
        if(d && j == 0) { // if previous year rot exists
            prev_revenues = d["totals"]["0"];
            text.append('tspan')
                .text((prev_revenues/window.aHelper.k(prev_revenues)).toFixed(2) + " " + window.aHelper.short_unit(prev_revenues) + " грн. - " + (year-1) + " р.")
                .attr("dy", "1.1em")
                .attr("x", -margin.left + 14)
                .style("font-weight", "normal");
            text.append('tspan')
                .text(function() {
                    if(revenues >= prev_revenues) {
                        return (100 - prev_revenues*100/revenues).toFixed(2) + "%"
                    }
                    if(revenues == 0) return "-100%";
                    return (100 - prev_revenues*100/revenues).toFixed(2) + "%";
                })
                .attr("dy", "1.1em")
                .attr("x", -margin.left + 14)
                .style("font-weight", "normal")
                .attr("fill", function(d) {return revenues >= prev_revenues ? "green" : "red"; });
        } else if(data["rows_rov"][year-1] && j == 1){
            prev_expences = data["rows_rov"][year-1]["totals"]["0"];
            text.append('tspan')
                .text((prev_expences/window.aHelper.k(prev_expences)).toFixed(2) + " " + window.aHelper.short_unit(prev_expences) + " грн. - " + (year-1) + " р.")
                .attr("dy", "1.1em")
                .attr("x", width - width/8 + margin.right + 4)
                .style("font-weight", "normal");
            text.append('tspan')
                .text(function() {
                    if(expences >= prev_expences) {
                        return (100 - prev_expences*100/expences).toFixed(2) + "%"
                    }
                    if(expences == 0) return "-100%";
                    return (100 - prev_expences*100/expences).toFixed(2) + "%";
                })
                .attr("dy", "1.1em")
                .attr("x", width - width/8 + margin.right + 4)
                .style("font-weight", "normal")
                .attr("fill", function(d) {return expences >= prev_expences ? "green" : "red"; });
        }

        text.append('tspan')
            .text(function(d) {
                        if(data["rows_rot"][year] && j == 0) return short_unit_rev + " грн";
                        if(data["rows_rov"][year] && j == 1) return short_unit_exp + " грн";
                        return "";
                    })
            .attr("y", -5)
            .attr("x", function() {
                if(j == 0) return -margin.left;
                return width - 2;
            })
            .style("font-weight", "bold");
    }

    append_status_frame_main(svg);

    // get fond name
    function get_fond(f) {
        var fond;
        switch (f) {
            case "1": fond = "Загальний фонд";
                break;
            case "2": fond = "Власні надходження";
                break;
            case "7": fond = "Спеціальний фонд";
                break;
            default:fond = f;
                break;
        }
        if(!energy.fonds[fond]) {
            energy.fonds[fond] = fond;
        }
        return fond;
    }

    // status frame with triangle to compare years amounts
    function append_status_frame(svg) {
        var rect = svg.append("g").attr("transform", "translate(0,0)");
        rect.append("rect")
            .attr("x", function(d) {
                if(d && !energy.fonds[d.name]) {
                    if (d.sourceLinks.length != 0 && d.targetLinks.length == 0) return -margin.left + 5;
                    return side_rect_width/2;
                }
            })
            .attr("y", function(d){
                if(d && !energy.fonds[d.name]) {
                    return d.dy/2 + 2;
                }
            })
            .style("fill", "none")
            .style("stroke", "lightgray")
            .style("stroke-width", 1)
            .attr("width", function(d){ return energy.amounts[d.name] ? side_rect_width - 10 : 0; })
            .attr("height", function(d){ return energy.amounts[d.name] ? "1.8em" : 0; });
        rect.append("path")
            .attr("d", d3.svg.symbol().type(function(d) {
                if(energy.amounts[d.name]) {
                    if(d.value > energy.amounts[d.name]) {return "triangle-up";}
                    if(d.value < energy.amounts[d.name]) {return "triangle-down";}
                    return "circle";
                }
                return "";
            }).size(function(d) {
                if(energy.amounts[d.name]) {
                    if(d.value != energy.amounts[d.name]) {return 3.5*3.5*3.5;}
                    return 3.5;
                }
                return 0;
            }))
            .style("fill", function(d) {
                if(energy.amounts[d.name]) {
                    if (d.value > energy.amounts[d.name]) {
                        return "green";
                    }
                    if (d.value < energy.amounts[d.name]) {
                        return "red";
                    }
                    return "none";
                }
            })
            .style("stroke", "white")
            .attr("transform", function(d) {
                if(d && !energy.fonds[d.name]) {
                    if (d.sourceLinks.length != 0 && d.targetLinks.length == 0) return "translate(" + (-margin.left + 5) + "," + (d.dy / 2 + 20) + ")";
                    return "translate(" + (side_rect_width/2) + "," + (d.dy / 2 + 20) + ")";
                }
            });
    }

    // status frame with triangle to compare total amounts
    function append_status_frame_main(svg) {
        for(var i = 0; i< 2; i++) {
            var rect = svg.append("g").attr("transform", "translate(0,0)");
            rect.append("rect")
                .attr("x", function() {
                    return i == 0 ? -margin.left + 5 : width - side_rect_width - 8;
                })
                .attr("y", -margin.top + 27)
                .style("fill", "none")
                .style("stroke", "lightgray")
                .style("stroke-width", 1)
                .attr("width", function(){
                    if((i == 0 && prev_revenues != 0) || (i == 1 && prev_expences != 0)) return side_rect_width + 25;
                    return 0;
                })
                .attr("height", function(){
                    if((i == 0 && prev_revenues != 0) || (i == 1 && prev_expences != 0)) return "1.8em";
                    return 0;
                });
            rect.append("path")
                .attr("d", d3.svg.symbol().type(function() {
                    if((i == 0 && revenues > prev_revenues) || (i == 1 && expences > prev_expences)) {return "triangle-up";}
                    if((i == 0 && revenues < prev_revenues) || (i == 1 && expences < prev_expences)) {return "triangle-down";}
                    if((i == 0 && revenues == prev_revenues) || (i == 1 && expences == prev_expences)) {return "circle";}
                    return "";
                }).size(function(d) {
                    if((i == 0 && prev_revenues == 0) || (i == 1 && prev_expences == 0)) {return 0;}
                    if((i == 0 && revenues != prev_revenues) || (i == 1 && expences != prev_expences)) {return 3.5*3.5*3.5;}
                    return 3.5;
                }))
                .style("fill", function(d) {
                    if((i == 0 && revenues > prev_revenues) || (i == 1 && expences > prev_expences)) {return "green";}
                    if((i == 0 && revenues < prev_revenues) || (i == 1 && expences < prev_expences)) {return "red";}
                    return "none";
                })
                .style("stroke", "white")
                .attr("transform", function(d) {
                    return i == 0 ? "translate(" + (-margin.left + 5) + "," + (-margin.top + 45) + ")" : "translate(" + (width - side_rect_width - 8) + "," + (-margin.top + 45) + ")";
                });
        }
    }
}

