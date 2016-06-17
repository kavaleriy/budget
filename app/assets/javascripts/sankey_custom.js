function get_sankey(data, year, percent, rot_file_id, rov_file_id) {

    var rot_month, rov_month;
    if(data["rows_rot"][year] && data["rows_rot"][year]['totals']['0']){
        rot_month = '0';
    } else {
        rot_month = get_taxonomy_month(data["rows_rot"],year);
        //rot_month = Math.max.apply(Math, Object.keys(data["rows_rot"][year]['totals']));
    }
    if(data["rows_rov"][year] && data["rows_rov"][year]['totals']['0']){
        rov_month = '0';
    } else {
        rov_month = get_taxonomy_month(data["rows_rov"],year);
        //rov_month = Math.max.apply(Math, Object.keys(data["rows_rov"][year]['totals']));
    }

    var svg_height;
    var shift = 1, curr_parent = null, curr_type = null, first_level_energy = null, child_level_energy = null;
    var data_labels = {}, children = {}, init_data_labels = {};
    var data_type = "fact"; // type for which build the tree

    switch(parseInt(percent)) {
        case 5:
            svg_height = 500;
            break;
        case 3:
            svg_height = 1000;
            break;
        case 0:
            svg_height = 1500;
            break;
        default:
            svg_height = 500;
            break;
    }

    $('#sankey_chart').html('').css("height", svg_height + 'px');
    $('#sankey_save').css("display", "inline");
    $('#back_sankey_save').css("display", "inline");
    $('#back_sankey_create').css("display", "none");

    var energy = {"nodes" : [],
                  "links" : [],
                  "amounts": [],
                  "fonds": []
                 };

    var amounts = [];

    // gather amounts for previous year
    function gather_previous_amounts(d) {
        for(var i in d) {     // level of fonds
            for(var j in d[i]) {     // level of keys in fonds
                var key = d[i][j].title || j;
                amounts[key] ? amounts[key] += d[i][j].amount : amounts[key] = d[i][j].amount;  // total amount for one key through all fonds
            }
        }
    }
    if(data["rows_rot"][year-1]){
        gather_previous_amounts(data["rows_rot"][year-1][rot_month]);
    }
    if(data["rows_rov"][year-1]){
        gather_previous_amounts(data["rows_rov"][year-1][rov_month]);
    }

    // gather data for revenues side
    var revenues = 0;
    var elseAmounts = [];
    var elseAmounts_prev = 0;

    if(data["rows_rot"][year]) {
        var d = data["rows_rot"][year][rot_month];
        revenues = data["rows_rot"][year]["totals"][rot_month];
        var names = {};
        for(var i in d) {
            var fond = get_fond(i);
            for(var j in d[i]) {
                var key = d[i][j].title || j;
                if(d[i][j].amount*100/revenues >= percent || names[j]) {
                    var pos, prev_amount;
                    if(names[j] || names[j] == 0) {
                        pos = names[j];
                    } else {
                        amounts[key] ? prev_amount = amounts[key] : prev_amount = 0;
                        energy.nodes.push({ "name": key,
                                            "xPos": 0,
                                            "prev_amount": prev_amount
                                          });
                        pos = energy.nodes.length-1;
                        names[j] = pos;
                    }
                    energy.links.push({ "source": pos,
                                        "target": fond,
                                        "value": d[i][j].amount,
                                        "key": j,
                                        "type": "rot",
                                        "pos": pos
                                      });
                } else {
                    elseAmounts[fond] ? elseAmounts[fond] += d[i][j].amount : elseAmounts[fond] = d[i][j].amount;
                    if(amounts[key] && !(names[j] || names[j] == 0)) {
                        elseAmounts_prev += amounts[key];
                    }
                }
            }
        }
    }

    if(Object.keys(elseAmounts).length != 0) {
        energy.nodes.push({"name": I18n.t("sankeys.aggr_revenues"),
                           "xPos": 0,
                           "prev_amount": 0
                          });
        var pos = energy.nodes.length-1;
        for(var key in elseAmounts) {
             energy.links.push({ "source": pos,
                                "target": parseInt(key),
                                "value": elseAmounts[key],
                                "pos": pos
                             });
        }
    }

    // gather data for expences side
    var expences = 0;
    elseAmounts = [];
    elseAmounts_prev = 0;

    if(data["rows_rov"][year]) {
        var d = data["rows_rov"][year][rov_month];
        expences = data["rows_rov"][year]["totals"][rov_month];
        var names = {};
        for(var i in d) {
            var fond = get_fond(i);
            for(var j in d[i]) {
                var key = d[i][j].title || j;
                if(d[i][j].amount*100/expences >= percent || names[j]) {
                    var pos, prev_amount;
                    if(names[j] || names[j] == 0) {
                        pos = names[j];
                    } else {
                        amounts[key] ? prev_amount = amounts[key] : prev_amount = 0;
                        energy.nodes.push({ "name": key,
                            "xPos": 2,
                            "prev_amount": prev_amount
                        });
                        pos = energy.nodes.length-1;
                        names[j] = pos;
                    }
                    energy.links.push({ "source": fond,
                                        "target": pos,
                                        "value": d[i][j].amount,
                                        "key": j,
                                        "type": "rov",
                                        "pos": pos
                                     });
                } else {
                    elseAmounts[fond] ? elseAmounts[fond] += d[i][j].amount : elseAmounts[fond] = d[i][j].amount;
                    if(amounts[key] && !(names[j] || names[j] == 0)) {
                        elseAmounts_prev += amounts[key];
                    }
                }
            }
        }
    }

    if(Object.keys(elseAmounts).length != 0) {
        energy.nodes.push({"name": I18n.t("sankeys.aggr_expences"),
                           "xPos": 2,
                           "prev_amount": 0
                          });
        var pos = energy.nodes.length-1;
        for(var key in elseAmounts) {
            energy.links.push({ "source": parseInt(key),
                "target": pos,
                "value": elseAmounts[key],
                "pos": pos
            });
        }
    }

    var side_rect_width = 60;
    var margin = {top: 80, right: 2*side_rect_width + 10, bottom: 30, left: side_rect_width + 10},
        width = $(document).width() - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom,
        sankey_center = 0;
    if(width < 400) width = 400;

    var formatNumber = d3.format(",.0f"),
        format = function(d) { return formatNumber(d) + " "; },
        color = d3.scale.category20();

    build_sankey(energy);

    function build_sankey(ext_energy) {
        var energy = jQuery.extend(true, {}, ext_energy);
        var k = 1;
        energy.nodes.forEach(function (d, i) {
            if(children.hasOwnProperty(i)) {
                d.xPos = children[i];
            }
            if(data_labels.hasOwnProperty(i)) {
                curr_type == "rot" ? d.xPos = 1 - shift*k : d.xPos = 1 + shift*k;
                data_labels[i] = d.xPos;
                k++;
            }
        });

        d3.select("#sankey_chart").selectAll('*').remove();
        var svg = d3.select("#sankey_chart").append("svg")
                                                .attr("width", width + margin.left + margin.right)
                                                .attr("height", height + margin.top + margin.bottom)
                                                .attr("version", 1.1)
                                                .attr("xmlns", "http://www.w3.org/2000/svg")
                                            .append("g")
                                                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var sankey = d3.sankey()
            .nodeWidth(15)
            .nodePadding(20)
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
            // .attr("class", "link")
            // add style attribute for html2canvas function (html2canvas not support css class )
            .style("fill",'none')
            .style("stroke",'#000')
            .style("stroke-opacity",'.2')
            // end style for html2canvas
            .attr("d", path)
            .style("stroke-width", function(d) { return Math.max(1, d.dy); })
            .sort(function(a, b) { return b.dy - a.dy; })
            .on("click", function(d){
                if (!data_labels[d.pos] || data_labels[d.pos] == 0 || data_labels[d.pos] == 2) {
                    if(d.key) {
                        get_subtree(d.key, d.type, d.pos);
                    } else if(d.node && d.node.children) {
                        get_children(d.node, d.pos, d.parent);
                    } else if (!d.node) { // case if it is Aggregated node
                        $('#percent_list a[data-value="0"]').click();
                    }
                } else {
                    if(d.key) {
                        reload_sankey(d.pos);
                    } else if(d.node && d.node.children) {
                        move_to_previous_level(d.parent);
                    }
                }
            });

        link.append("title")
            .text(function(d) { return d.source.name + " → " + d.target.name + "\n" + format(d.value); });

        var node = svg.append("g").selectAll(".node")
            .data(energy.nodes)
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", function(d) {
                if(d.xPos == 1 && sankey_center == 0) {
                    sankey_center = d.x + 75;
                }
                return "translate(" + d.x + "," + d.y + ")";
            })
            .call(d3.behavior.drag()
                .origin(function(d) { return d; })
                .on("dragstart", function() { this.parentNode.appendChild(this); })
                .on("drag", dragmove));

        node.append("rect")
            .attr("height", function(d) { return d.dy; })
            .attr("width", function(d) {
                if(d.xPos == 1) return 150;
                return sankey.nodeWidth();
            } )
            .style("fill", function(d) { return d.color = color(d.name.replace(/ .*/, "")); })
            .style("stroke", function(d) { return d3.rgb(d.color).darker(2); })
            .append("title")
            .text(function(d) { return d.name + "\n" + format(d.value); });

        // side rectangles
        node.append("rect")
            .attr("x", function(d) {
                if(d.xPos == 0) return -margin.left;
                return side_rect_width/2 - 5;})
            .attr("y", function(d) { return (d.dy < 45 && d.prev_amount != 0) ? -10 : 0; })
            .style("fill", "#F0F0F0")
            .style("stroke", "none")
            .attr("width", side_rect_width)
            .attr("height", function(d) { if( d.xPos != 0 && d.xPos != 2 ) return 0;
                return (d.dy < 45 && d.prev_amount != 0) ? 45 : d.dy; });
        // info for side rectangles
        var k_rev = window.aHelper.k(5*revenues/100);
        var k_exp = window.aHelper.k(5*expences/100);
        var side_text = node.append("text")
            .text(function(d){
                if(d.xPos == 0) return (d.value/k_rev).toFixed(2);
                if(d.xPos == 2) return (d.value/k_exp).toFixed(2);
                return "";
            })
            .attr("text-anchor", "middle")
            .attr("x", function(d) {
                if(d.xPos == 0) return -margin.left/2 - 5;
                return side_rect_width - 5;
            })
            .attr("y", function(d) {
                if(d.prev_amount != 0) return d.dy/2 - 10;
                return d.dy/2 + 4;
            })
            .style("font-size", "0.7em")
            .style("font-weight", "bold");

        side_text.append('tspan')
            .text(function(d) {
                if(d.prev_amount != 0) {
                    if(d.xPos == 0) return (d.prev_amount/k_rev).toFixed(2);
                    if(d.xPos == 2) return (d.prev_amount/k_exp).toFixed(2);
                }
                return "";
            })
            .attr("dy", "1.1em")
            .attr("x", function(d) {
                if(d.xPos == 0) return -margin.left/2 - 5;
                return side_rect_width - 5;})
            .style("font-weight", "normal")
            .attr("fill", "darkslategray");

        side_text.append('tspan')
            .text(function(d) {
                if(d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) {
                    var x = 0;
                    d.prev_amount < d.value ? x = 100 - d.prev_amount*100/d.value : x = d.value*100/d.prev_amount - 100;
                    return x.toFixed(2) + " %";
                }
                return "";
            })
            .attr("dy", "1.1em")
            .attr("x", function(d) {
                if(d.xPos == 0) return -margin.left/2 - 5;
                return side_rect_width - 5;})
            .style("font-weight", "normal")
            .attr("fill", function(d) { return  d.prev_amount <= d.value ? "green" : "red"});

        append_status_frame(node);

        node.append("text")
            .attr("x", -6)
            .attr("y", function(d) { return d.dy / 2; })
            .attr("dy", ".35em")
            .attr("text-anchor", "end")
            .attr("transform", null)
            .text(function(d) { return d.name; })
            .filter(function(d) { return d.x < width / 2; })
            .attr("x", function(d) { if(energy.fonds[d.name] || energy.fonds[d.name] == 0) return 75;
                return 6 + sankey.nodeWidth(); })

            .attr("y", function(d) { return (d.dy < 15 && (energy.fonds[d.name] || energy.fonds[d.name] == 0)) ? -8 : d.dy / 2;})
            .attr("text-anchor", function(d) { if(energy.fonds[d.name] || energy.fonds[d.name] == 0) return "middle";
                return "start"; });

        function dragmove(d) {
            d3.select(this).attr("transform", "translate(" + d.x + "," + (d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))) + ")");
            sankey.relayout();
            link.attr("d", path);
        }

        // central rectangle for General and Special funds
        svg.append("rect")
            .attr("x", sankey_center - 83)
            .attr("y", -margin.top + 1)
            .style("fill", "none")
            .style("stroke", "darkgray")
            .style("stroke-width", 2)
            .style("stroke-dasharray", "10,10")
            .attr("rx", 10)
            .attr("ry", 10)
            .attr("width", 166)
            .attr("height", height + margin.top + margin.bottom - 2);

        svg.append("text")
            .attr("x", sankey_center)
            .attr("y", -margin.top + 25)
            .attr("text-anchor", "middle")
            .style("fill", "darkgray")
            .style("font-size", "0.7em")
            .style("font-weight", "bold")
            .text(I18n.t("sankeys.budget") + year + I18n.t("short_units.year"));

        // rectangles for status bar (total amounts)
        var arrow_length = 70;
        for(var i = 0; i < 3; i++) {
            var status_bar = svg.append("g").attr("transform", "translate(0,0)");
//            status_bar.append("rect")
//                .attr("x", function(){
//                    if(i == 0) return sankey_center/2 - width/12;
//                    if(i == 1) return sankey_center - 79;
//                    return 3*sankey_center/2 - width/12;
//                })
//                .attr("y", function(){
//                    if(i == 1) return -margin.top/2 + 1;
//                    return -margin.top + 1;
//                })
//                .attr("rx", 10)
//                .attr("ry", 10)
//                .style("fill", function(){
//                    if(i == 1) {
//                        if(revenues > expences) return "blue";
//                        if(revenues < expences) return "red";
//                        if(revenues == expences) return "gray";
//                    }
//                    return "none";
//                })
//                .style("stroke", "#082757")
//                .style("stroke-width", 2)
//                .attr("width", function(){
//                    if(i == 1) return 158;
//                    return width/6;
//                })
//                .attr("height", function(){
//                    if(i == 1) return margin.top/2 - 10;
//                    return margin.top/2;
//                });

            if(i != 1) {
                status_bar.append("g")
                            .attr("transform", function() {if(i == 0) return "translate(" + (sankey_center - 83 - arrow_length) + "," + (-margin.top/2) + ")";
                                                           return "translate(" + (sankey_center + 83) + "," + (-margin.top/2) + ")"})
                          .append("polyline")
                            .attr("points", "0,10 0,20 50,20 50,25 70,15 50,5 50,10")
                            .attr("stroke-width", "1px")
                            .attr("stroke", function() {if(i == 0) return d3.rgb("green").darker(2);
                                                        return d3.rgb("red").darker(2)})
                            .style("fill", function() {if(i == 0) return "green";
                                                           return "red"});
                status_bar.append("text")
                    .attr("x", function(){
                        if(i == 0) return sankey_center - 83 - arrow_length - 10;
                        return sankey_center + 83 + arrow_length + 10;
                    })
                    .attr("y", -margin.top/2 + 20)
                    .attr("text-anchor", function(){
                        if(i == 0) return "end";
                        return "start";
                    })
                    .style("fill", "#082757")
                    .style("font-size", "0.8em")
                    .style("font-weight", "bold")
                    .text(function(){if(i == 0) return I18n.t("sankeys.revenues") + " - " + (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + I18n.t("short_units.unit");
                                     return I18n.t("sankeys.expences") + " - " + (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + I18n.t("short_units.unit");});
            } else {
                status_bar.append("g")
                            .attr("transform", function() { return "translate(" + (sankey_center - 65) + "," + (-margin.top/2) + ")"; })
                          .append("circle")
                            .attr("r", 10)
                            .attr("cx", 10)
                            .attr("cy", 15)
                            .attr("stroke-width", "1px")
                            .attr("stroke", 'black')
                            .style("fill", function() {if(revenues > expences) return "green";
                                                       if(revenues < expences) return "red";
                                                       if(revenues == expences) return "yellow";});
                status_bar.append("text")
                            .attr("x", sankey_center + 10)
                            .attr("y", -margin.top/2 + 15)
                            .attr("text-anchor", "middle")
                            .style("fill", "#082757")
                            .style("font-size", "0.8em")
                            .style("font-weight", "bold")
                            .text(function(){
                                            if(revenues > expences) return I18n.t("sankeys.surplus");
                                            if(revenues < expences) return I18n.t("sankeys.deficit");
                                            if(revenues == expences) return I18n.t("sankeys.balance");})
                          .append("tspan")
                            .attr("dy", "1.2em")
                            .attr("x", sankey_center + 10)
                            .text(function() {var diff = (Math.abs(revenues - expences)/window.aHelper.k(Math.abs(revenues - expences))).toFixed(2) + " " + window.aHelper.short_unit(Math.abs(revenues - expences)) + I18n.t("short_units.unit")
                                              if(revenues != expences) return diff;})
            }
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
                    return width - margin.left - 10;
                })
                .attr("y", -margin.top + 1 )
                .style("fill", "#F0F0F0")
                .style("stroke", "none")
                .attr("width", margin.right + 20)
                .attr("height", margin.top - 20);

            var text = side_bars.append("text")
                .attr("x", function(){if(j == 0) return -margin.left + 5; return width - margin.left - 5})
                .attr("y", -margin.top + 25)
                .attr("text-anchor", "start")
                .style("font-size", "0.7em")
                .style("font-weight", "bold");

            text.append('tspan')
                .text(function() {
                    if(j == 0) return (revenues/window.aHelper.k(revenues)).toFixed(2) + " " + window.aHelper.short_unit(revenues) + I18n.t("short_units.unit") + " - " + year + I18n.t("short_units.year");
                    return (expences/window.aHelper.k(expences)).toFixed(2) + " " + window.aHelper.short_unit(expences) + I18n.t("short_units.unit") + " - " + year + I18n.t("short_units.year");
                });

            d = data["rows_rot"][year-1];
            if(d && j == 0) { // if previous year rot exists
                prev_revenues = d["totals"][rot_month];
                text.append('tspan')
                    .text((prev_revenues/window.aHelper.k(prev_revenues)).toFixed(2) + " " + window.aHelper.short_unit(prev_revenues) + I18n.t("short_units.unit") + " - " + (year-1) + I18n.t("short_units.year"))
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
                prev_expences = data["rows_rov"][year-1]["totals"][rov_month];
                text.append('tspan')
                    .text((prev_expences/window.aHelper.k(prev_expences)).toFixed(2) + " " + window.aHelper.short_unit(prev_expences) + I18n.t("short_units.unit") + " - " + (year-1) + I18n.t("short_units.year"))
                    .attr("dy", "1.1em")
                    .attr("x", width - margin.left + 5)
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
                    .attr("x", width - margin.left + 5)
                    .style("font-weight", "normal")
                    .attr("fill", function(d) {return expences >= prev_expences ? "green" : "red"; });
            }

            text.append('tspan')
                .text(function(d) {
                    if(data["rows_rot"][year] && j == 0) return short_unit_rev + I18n.t("short_units.unit");
                    if(data["rows_rov"][year] && j == 1) return short_unit_exp + I18n.t("short_units.unit");
                    return "";
                })
                .attr("y", -5)
                .attr("x", function() {
                    if(j == 0) return -margin.left;
                    return width + 8;
                })
                .style("font-weight", "bold");
        }

        append_status_frame_main(svg);

        // status frame with triangle to compare years amounts
        function append_status_frame(svg) {
            var rect = svg.append("g").attr("transform", "translate(0,0)");
            rect.append("rect")
                .attr("x", function(d) {
                    if(d && d.xPos == 0) return -margin.left + 5;
                    if(d && d.xPos == 2) return side_rect_width/2;
                })
                .attr("y", function(d){
                    if(d && (d.xPos == 0 || d.xPos == 2)) {
                        return d.dy/2 - 8;
                    }
                })
                .style("fill", "none")
                .style("stroke", "lightgray")
                .style("stroke-width", 1)
                .attr("width", function(d){ return (d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) ? side_rect_width - 10 : 0; })
                .attr("height", function(d){ return (d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) ? "1.8em" : 0; });
            rect.append("path")
                .attr("d", d3.svg.symbol().type(function(d) {
                    if(d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) {
                        if(d.value > d.prev_amount) {return "triangle-up";}
                        if(d.value < d.prev_amount) {return "triangle-down";}
                        return "circle";
                    }
                    return "";
                }).size(function(d) {
                    if(d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) {
                        if(d.value != d.prev_amount) {return 3.5*3.5*3.5;}
                        return 3.5;
                    }
                    return 0;
                }))
                .style("fill", function(d) {
                    if(d.prev_amount != 0 && (d.xPos == 0 || d.xPos == 2)) {
                        if (d.value > d.prev_amount) {
                            return "green";
                        }
                        if (d.value < d.prev_amount) {
                            return "red";
                        }
                        return "none";
                    }
                })
                .style("stroke", "white")
                .attr("transform", function(d) {
                    if (d && d.xPos == 0) return "translate(" + (-margin.left + 5) + "," + (d.dy / 2 + 10) + ")";
                    if (d && d.xPos == 2) return "translate(" + (side_rect_width/2) + "," + (d.dy / 2 + 10) + ")";
                });
        }

        // status frame with triangle to compare total amounts
        function append_status_frame_main(svg) {
            for(var i = 0; i< 2; i++) {
                var rect = svg.append("g").attr("transform", "translate(0,0)");
                rect.append("rect")
                    .attr("x", function() {
                        return i == 0 ? -margin.left + 5 : width - margin.left - 5;
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
                        return i == 0 ? "translate(" + (-margin.left + 5) + "," + (-margin.top + 45) + ")" : "translate(" + (width - margin.left - 5) + "," + (-margin.top + 45) + ")";
                    });
            }
        }
    }

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
        if(!energy.fonds[fond] && energy.fonds[fond] != 0) {
            energy.nodes.push({"name": fond,
                "xPos": 1
            });
            energy.fonds[fond] = energy.nodes.length-1;
            return energy.fonds[fond];
        }
        for(var key in energy.fonds) {
            if(key == fond) {
                return energy.fonds[fond];
            }
        }
    }

    function get_subtree(key, type, pos) {
        var file_id;
        if(rot_file_id == 0 && rov_file_id == 0) {
            file_id = $('#select_' + type + ' option:selected').val();
        } else {
            type == "rot" ? file_id = rot_file_id : file_id = rov_file_id;
        }
        var taxonomy, xPos;
        curr_type = type;
        curr_parent = pos;
        if(type == "rot") {
            taxonomy = "kkd_a";
            xPos = 0;
        } else if(type == "rov") {
            taxonomy = "ktfk_aaa";
            xPos = 2;
        }

        d3.json("/widgets/visify/get_bubblesubtree/" + file_id + "/" + taxonomy + "/" + key, function(data) {
            data_labels = {};
            data_labels[pos] = xPos;
            children = {};
            shift = 0.5;
            first_level_energy = jQuery.extend(true, {}, energy);
            child_level_energy = jQuery.extend(true, {}, energy);
            init_data_labels = jQuery.extend(true, {}, data_labels);
            var d = data.children;
            var total_sum = data["amount"][data_type][year]["0"]["total"];
            elseAmounts = 0;
            elseAmounts_prev = 0;

            for(var i in d) {
                if(d[i]["amount"][data_type]) {
                    var d_amount = d[i]["amount"][data_type][year]["0"]["total"];
                    var prev_amount = 0;
                    if(d[i]["amount"][data_type][year-1] && d[i]["amount"][data_type][year-1]["0"] && d[i]["amount"][data_type][year-1]["0"]["total"]) {
                        prev_amount = d[i]["amount"][data_type][year-1]["0"]["total"];
                    }
                    if(d_amount*100/total_sum >= percent) {
                        var key = d[i].label || d[i].key;
                        first_level_energy.nodes.push({ "name": key,
                            "xPos": xPos,
                            "prev_amount": prev_amount,
                            "parent": pos
                        });
                        var curr_pos = first_level_energy.nodes.length-1;
                        children[curr_pos] = xPos;
                        first_level_energy.links.push({ "source": type == "rot" ? curr_pos : pos,
                            "target": type == "rot" ? pos : curr_pos,
                            "value": d_amount,
                            "node": d[i],
                            "type": type,
                            "pos": curr_pos,
                            "parent": pos
                        });
                    } else {
                        elseAmounts += d_amount;
                        elseAmounts_prev += prev_amount;
                    }
                }
            }
            if(elseAmounts != 0) {
                first_level_energy.nodes.push({ "name": type == "rot" ? I18n.t("sankeys.aggr_revenues") : I18n.t("sankeys.aggr_expences"),
                    "xPos": xPos,
                    "prev_amount": 0,
                    "parent": pos
                });
                curr_pos = first_level_energy.nodes.length-1;
                first_level_energy.links.push({ "source": type == "rot" ? curr_pos : pos,
                    "target": type == "rot" ? pos : curr_pos,
                    "value": elseAmounts,
                    "pos": curr_pos,
                    "parent": pos
                });
            }

            build_sankey(first_level_energy);
        });
    }

    function get_children(node, pos, parent) {
        if(parent == curr_parent) {
            child_level_energy = $.extend(true, {}, first_level_energy);
            data_labels = jQuery.extend(true, {}, init_data_labels);
        }
        var energy = $.extend(true, {}, child_level_energy);
        for(var i in children) {
            if ((data_labels[i] || data_labels[i] == 0) && parent == curr_parent) {
                delete data_labels[i];
            }
        }
        var xPos;
        if(curr_type == "rot") {
            xPos = 0;
        } else if(curr_type == "rov") {
            xPos = 2;
        }
        data_labels[pos] = xPos;
        var length = Object.keys(data_labels).length + 1;
        shift = 1/length;
        var d = node.children;
        var total_sum = node["amount"][data_type][year]["0"]["total"];
        elseAmounts = 0;
        elseAmounts_prev = 0;
        for(var i in d) {
            var d_amount = 0;
            var prev_amount = 0;
            if(d[i]["amount"][data_type] && d[i]["amount"][data_type][year-1] && d[i]["amount"][data_type][year-1]["0"] && d[i]["amount"][data_type][year-1]["0"]["total"]) {
                prev_amount = d[i]["amount"][data_type][year-1]["0"]["total"];
            }
            if(d[i]["amount"][data_type] && d[i]["amount"][data_type][year]) {
                if (d[i]["amount"][data_type][year]["0"]) {
                    d_amount = d[i]["amount"][data_type][year]["0"]["total"];
                } else {
                    var count = d[i]["amount"][data_type][year];
                    for(var j in count) {
                        d_amount += count[j]["total"];
                    }
                }
            } else {
                continue;
            }
            if(d_amount*100/total_sum >= percent) {
                var key = d[i].label || d[i].key;
                energy.nodes.push({ "name": key,
                    "xPos": xPos,
                    "prev_amount": prev_amount,
                    "parent": pos
                });
                var curr_pos = energy.nodes.length-1;
                energy.links.push({ "source": curr_type == "rot" ? curr_pos : pos,
                                    "target": curr_type == "rot" ? pos : curr_pos,
                                    "value": d_amount,
                                    "node": d[i],
                                    "pos": curr_pos,
                                    "parent": pos
                                });
            } else {
                elseAmounts += d_amount;
                elseAmounts_prev += prev_amount;
            }
        }
        if(elseAmounts != 0) {
            energy.nodes.push({ "name": curr_type == "rot" ? I18n.t("sankeys.aggr_revenues") : I18n.t("sankeys.aggr_expences"),
                "xPos": xPos,
                "prev_amount": 0,
                "parent": pos
            });
            var curr_pos = energy.nodes.length-1;
            energy.links.push({ "source": curr_type == "rot" ? curr_pos : pos,
                "target": curr_type == "rot" ? pos : curr_pos,
                "value": elseAmounts,
                "pos": curr_pos,
                "parent": pos
            });
        }
        child_level_energy = $.extend(true, {}, energy);

        build_sankey(energy);
    }

    function reload_sankey(pos) {
        data_labels = {};
        energy.nodes[pos].xPos < 1 ? energy.nodes[pos].xPos = 0 : energy.nodes[pos].xPos = 2;
        build_sankey(energy);
    }

    function move_to_previous_level(parent) {
        for(var i in child_level_energy.nodes) {
            if(child_level_energy.nodes[i].parent > parent) {
                delete child_level_energy.nodes[i];
                delete data_labels[i];
            }
        }
        for(var i in child_level_energy.links) {
            if(child_level_energy.links[i].parent > parent) {
                delete child_level_energy.links[i];
            }
        }
        var length = Object.keys(data_labels).length;
        shift = 1/length;
        build_sankey(child_level_energy);
    }

    function get_taxonomy_month(taxonomy,year){
        var month = '0';
        if(taxonomy.hasOwnProperty(year) &&  taxonomy[year].hasOwnProperty('totals')){
            month = Math.max.apply(Math, Object.keys(taxonomy[year]['totals']));
        }

        return month;
    }
}

